
-- =============================================================================
-- PHẦN 1: PHÂN TÍCH LOGIC (THEORETICAL ANALYSIS)
-- =============================================================================

/* 
   - Tham số IN: p_Month, p_Year dùng để truyền dữ liệu lọc vào trong thủ tục.
   - Tham số OUT: p_TotalRevenue đóng vai trò như một "thùng chứa" kết quả. 
     Khi thủ tục chạy xong, giá trị sẽ được lưu vào đây để bên ngoài có thể lấy ra.
   - Từ khóa INTO: Đây là từ khóa then chốt để gán kết quả của hàm SUM() 
     trực tiếp vào biến OUT p_TotalRevenue.
*/

-- =============================================================================
-- PHẦN 2: TRIỂN KHAI MÃ NGUỒN (IMPLEMENTATION)
-- =============================================================================

-- Xóa thủ tục cũ nếu tồn tại
DROP PROCEDURE IF EXISTS GetTotalRevenueByMonth;

DELIMITER //

CREATE PROCEDURE GetTotalRevenueByMonth(
    IN p_Month INT, 
    IN p_Year INT, 
    OUT p_TotalRevenue DECIMAL(15, 2) -- Tham số trả về
)
BEGIN
    -- Tính tổng tiền và gán trực tiếp vào biến OUT p_TotalRevenue
    SELECT SUM(TotalPrice) 
    INTO p_TotalRevenue
    FROM Orders
    WHERE MONTH(OrderDate) = p_Month 
      AND YEAR(OrderDate) = p_Year;
      
    /* 
       Lưu ý: Nếu không tìm thấy dữ liệu phù hợp, p_TotalRevenue sẽ trả về NULL.
       Để chuyên nghiệp hơn, có thể dùng COALESCE(SUM(TotalPrice), 0) để trả về 0 thay vì NULL.
    */
END //

DELIMITER ;

-- =============================================================================
-- PHẦN 3: HƯỚNG DẪN KIỂM TRA KẾT QUẢ (TESTING)
-- =============================================================================

/* 
   Vì đây là tham số OUT, bạn không thể gọi thủ tục theo cách thông thường.
   Bạn cần một biến phiên (session variable) để hứng kết quả:
*/

-- 1. Gọi thủ tục và truyền biến @Result để hứng dữ liệu
-- Ví dụ: Tính doanh thu tháng 5 năm 2026
CALL GetTotalRevenueByMonth(5, 2026, @Result);

-- 2. Kiểm tra giá trị bên trong biến @Result
SELECT @Result AS 'Tong_Doanh_Thu_Thang_05_2026';
