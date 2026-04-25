const multer = require('multer');
const path = require('path');
const fs = require('fs');
const crypto = require('crypto');

/**
 * وظيفة رفع الصور وتكرارها وتخزينها في مجلدات منظمة
 */
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        const tempDir = path.join(__dirname, '../uploads/temp');
        if (!fs.existsSync(tempDir)) {
            fs.mkdirSync(tempDir, { recursive: true });
        }
        cb(null, tempDir);
    },
    filename: (req, file, cb) => {
        // اسم مؤقت للملف
        cb(null, `temp-${Date.now()}-${file.originalname}`);
    }
});

const upload = multer({ 
    storage,
    // limits: { fileSize: 5 * 1024 * 1024 }, // حد أقصى 5 ميجا باييت
    fileFilter: (req, file, cb) => {
        const filetypes = /jpeg|jpg|png|webp/;
        const mimetype = filetypes.test(file.mimetype);
        const extname = filetypes.test(path.extname(file.originalname).toLowerCase());

        if (mimetype && extname) {
            return cb(null, true);
        }
        cb(new Error("يدعم تحميل أنواع الملفات التالية فقط - " + filetypes));
    }
});

/**
 * Middleware لمعالجة الصورة بعد الرفع (التنظيم وإزالة التكرار)
 * @param {string} subFolder - المجلد الفرعي (users, events, etc.)
 * @param {string} fieldName - اسم الحقل في الـ request
 */
const uploadTo = (subFolder, fieldName) => {
    return [
        upload.single(fieldName),
        async (req, res, next) => {
            if (!req.file) return next();

            const tempPath = req.file.path;
            
            try {
                // 1. حساب الـ Hash للملف لمنع التكرار
                const fileBuffer = fs.readFileSync(tempPath);
                const hash = crypto.createHash('md5').update(fileBuffer).digest('hex');
                const ext = path.extname(req.file.originalname).toLowerCase();
                const fileName = `${hash}${ext}`;
                
                // 2. تحديد المجلد الهدف
                const targetDir = path.join(__dirname, '../uploads', subFolder);
                const targetPath = path.join(targetDir, fileName);

                if (!fs.existsSync(targetDir)) {
                    fs.mkdirSync(targetDir, { recursive: true });
                }

                // 3. التحقق من وجود الملف مسبقاً
                if (fs.existsSync(targetPath)) {
                    // إذا كان موجوداً، نحذف الملف المؤقت ونستخدم المسار القديم
                    fs.unlinkSync(tempPath);
                    console.log(`♻️ تم اكتشاف صورة مكررة، إعادة استخدام: ${fileName}`);
                } else {
                    // إذا كان جديداً، ننقله للمجلد المنظم
                    fs.renameSync(tempPath, targetPath);
                    console.log(`📦 تم تخزين صورة جديدة في: ${subFolder}/${fileName}`);
                }

                // 4. تحديث بيانات الـ req.file ليستخدمها الـ Controller
                // نحتاج لمسار نسبي يبدأ بـ uploads ليتمكن الـ static middleware من عرضه
                const relativePath = path.join('uploads', subFolder, fileName).replace(/\\/g, '/');
                
                req.file.path = targetPath;
                req.file.filename = fileName;
                req.file.destination = targetDir;
                
                // إضافة المسار للـ body ليتمكن الـ controller من حفظه في قاعدة البيانات بسهولة
                // بعض الـ controllers تستخدم req.file.path والبعض req.body[fieldName]
                req.body[fieldName] = relativePath;
                
                next();
            } catch (error) {
                console.error('❌ خطأ في معالجة رفع الملف:', error);
                if (fs.existsSync(tempPath)) fs.unlinkSync(tempPath);
                res.status(500).json({ message: 'Error processing image upload', error: error.message });
            }
        }
    ];
};

module.exports = {
    uploadTo
};
