
-- =============================================================================
-- PHẦN 1: KHỞI TẠO CẤU TRÚC DỮ LIỆU (DATABASE SETUP)
-- =============================================================================

-- Xóa dữ liệu cũ nếu tồn tại để tránh xung đột
DROP PROCEDURE IF EXISTS CancelAppointment;
DROP TABLE IF EXISTS Appointments;

-- Tạo bảng lịch khám
CREATE TABLE Appointments (
    appointment_id INT PRIMARY KEY,
    patient_name VARCHAR(100),
    appointment_date DATETIME,
    status VARCHAR(20) -- Trạng thái: 'Pending', 'Completed', 'Cancelled'
);

-- Chèn dữ liệu mẫu để kiểm thử
INSERT INTO Appointments (appointment_id, patient_name, appointment_date, status) 
VALUES 
(101, N'Nguyễn Văn An', '2026-05-20 08:00:00', 'Pending'),   -- Lịch đang chờ (Cho phép hủy)
(102, N'Lê Thị Bình', '2026-05-10 10:30:00', 'Completed'), -- Lịch đã xong (Cấm hủy)
(103, N'Trần Tuấn Cảnh', '2026-05-25 14:00:00', 'Pending');   -- Lịch đang chờ (Cho phép hủy)

-- =============================================================================
-- PHẦN 2: TRIỂN KHAI STORED PROCEDURE ĐÃ VÁ LỖI (LOGIC FIX)
-- =============================================================================

DELIMITER //

CREATE PROCEDURE CancelAppointment(IN p_appointment_id INT)
BEGIN
    /* THAY ĐỔI QUAN TRỌNG: 
       Thêm điều kiện [AND status = 'Pending'] vào mệnh đề WHERE.
       Điều này đảm bảo hệ thống chỉ tác động lên những bản ghi hợp lệ theo quy tắc.
    */
    UPDATE Appointments
    SET status = 'Cancelled'
    WHERE appointment_id = p_appointment_id 
      AND status = 'Pending';
      
    -- Thông báo trạng thái thực thi (Tùy chọn thêm để quan sát)
    SELECT CONCAT('Processed cancellation for ID: ', p_appointment_id) AS Execution_Log;
END //

DELIMITER ;

-- =============================================================================
-- PHẦN 3: KỊCH BẢN KIỂM THỬ NGHIỆM THU (TESTING)
-- =============================================================================

-- 1. Xem trạng thái ban đầu
SELECT * FROM Appointments;

-- 2. THỬ NGHIỆM 1: Hủy một lịch đang ở trạng thái 'Pending' (Hợp lệ)
-- Kết quả mong đợi: Status của ID 101 chuyển sang 'Cancelled'
CALL CancelAppointment(101);

-- 3. THỬ NGHIỆM 2: Hủy một lịch đã 'Completed' (Bẫy dữ liệu)
-- Kết quả mong đợi: Status của ID 102 vẫn giữ nguyên là 'Completed'
CALL CancelAppointment(102);

-- 4. KIỂM TRA KẾT QUẢ CUỐI CÙNG
SELECT * FROM Appointments;

/*******************************************************************************
-- NHẬN XÉT SAU KIỂM THỬ:
-- ID 101: Đã được cập nhật thành 'Cancelled' vì thỏa mãn điều kiện 'Pending'.
-- ID 102: Không bị thay đổi vì không thỏa mãn điều kiện status = 'Pending'.
-- => Lỗi logic đã được khắc phục hoàn toàn!
*******************************************************************************/
