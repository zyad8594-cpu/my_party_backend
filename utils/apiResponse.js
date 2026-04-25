/**
 * أداة استجابة واجهة برمجة التطبيقات الموحدة
 */
class ApiResponse {
    static success(res, data, message = 'Success', statusCode = 200) {
        return res.status(statusCode).json({
            success: true,
            message,
            data
        });
    }

    static error(res, message = 'خطأ في الخادم الداخلي', statusCode = 400, error = null) {
        const response = {
            success: false,
            message,
        };
        if (error) {
            response.error = process.env.NODE_ENV === 'development' ? error : undefined;
        }
        return res.status(statusCode).json(response);
    }
}

module.exports = ApiResponse;
