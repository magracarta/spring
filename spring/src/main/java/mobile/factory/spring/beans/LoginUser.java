package mobile.factory.spring.beans;

import java.util.Collection;

import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.User;

/**
 * <pre>
 * 이클래스는
 * </pre>
 *
 * @author JY.Eom
 * @date 2017-04-25
 * @time 13:56:62
 */
public abstract class LoginUser extends User {
	/**
	 * 
	 */
	private static final long serialVersionUID = 4623460567562554621L;

	public LoginUser(String username, String password, boolean enabled, boolean accountNonExpired, boolean credentialsNonExpired, boolean accountNonLocked,
			Collection<? extends GrantedAuthority> authorities) {
		super(username, password, enabled, accountNonExpired, credentialsNonExpired, accountNonLocked, authorities);
	}

	public LoginUser(String username, String password, Collection<? extends GrantedAuthority> authorities) {
		super(username, password, authorities);
	}

}
// :)--