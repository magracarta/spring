package mobile.factory.exception;

/**
 * 이클래스는 유효성 체크
 * @author JY.Eom
 * 
 */
public class XCheckException extends RuntimeException {
	private static final long serialVersionUID = 3237778100706408524L;

	private String errorCode = "";

	public XCheckException(String errorCode, String message) {
		super(message);
		this.errorCode = errorCode;
	}

	public String getErrorCode() {
		return errorCode;
	}
}
