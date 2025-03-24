package mobile.factory.exception;

/**
 * <pre>
 *  이 클래스는 디비 컬럼에 insert, update시 정해놓은 길이보다 큰값이 들어 왔을때 발생하는 오류
 * </pre>
 *
 * @author JeongY.Eom
 * @date 2023.06.16
 * @time 15:16
**/
public class ColumnLengthOverException extends RuntimeException{
    private static final long serialVersionUID = -6022309176103165712L;

    private String errorCode = "";

    public ColumnLengthOverException(String errorCode, String message) {
        super(message);
        this.errorCode = errorCode;
    }

    public String getErrorCode() {
        return errorCode;
    }
}
