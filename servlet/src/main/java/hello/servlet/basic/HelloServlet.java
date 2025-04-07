package hello.servlet.basic;

import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;

import java.io.IOException;

@WebServlet(name = "helloServlet" , urlPatterns = "/hello")
public class HelloServlet extends HttpServlet {

    @Override
    public void service(ServletRequest request, ServletResponse response) throws ServletException, IOException {

        System.out.println("Hello Servlet");
        System.out.println("request = " + request);
        System.out.println("response = " + response);
        String username = request.getParameter("username");
        System.out.println("username = " + username);

        response.setContentType("text/plain");
        request.setCharacterEncoding("utf-8");
        response.getWriter().write("Hello " + username);

    }

}
