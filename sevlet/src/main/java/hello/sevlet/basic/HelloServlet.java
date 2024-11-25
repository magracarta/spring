package hello.sevlet.basic;

import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;

import java.io.IOException;

@WebServlet(name = "helloServlet" , urlPatterns = "/hello")
public class HelloServlet extends HttpServlet {

    @Override
    public void service(ServletRequest req, ServletResponse res) throws ServletException, IOException {

        System.out.println("HelloServlet.service");
        System.out.println("req = " + req);
        System.out.println("res = " + res);

        String username = req.getParameter("username");
        System.out.println("username = " + username);

        res.setContentType("text/html");
        res.setCharacterEncoding("UTF-8");
        res.getWriter().write("hello " + username);

    }
}
