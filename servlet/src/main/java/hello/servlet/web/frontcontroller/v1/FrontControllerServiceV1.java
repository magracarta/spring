package hello.servlet.web.frontcontroller.v1;

import hello.servlet.web.frontcontroller.v1.MemberFormControllerV1.MemberFormControllerV1;
import hello.servlet.web.frontcontroller.v1.MemberFormControllerV1.MemberListControllerV1;
import hello.servlet.web.frontcontroller.v1.MemberFormControllerV1.MemberSaveControllerV1;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@WebServlet(name = "frontControllerServiceV1" , urlPatterns = "/front-controller/v1/*")
public class FrontControllerServiceV1 extends HttpServlet {
    private Map<String, ControllerV1> controllerMap = new HashMap<>();

    public FrontControllerServiceV1() {
        controllerMap.put("/front-controller/v1/members/new-form", new MemberFormControllerV1());
        controllerMap.put("/front-controller/v1/members/save", new MemberSaveControllerV1());
        controllerMap.put("/front-controller/v1/members", new MemberListControllerV1());
    }

    @Override
    protected void service(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("FrontControllerServiceV1::service");
        String requestURI = request.getRequestURI();

        ControllerV1 controllerV1 = controllerMap.get(requestURI);
        if(controllerV1 == null){
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            return;
        };

        controllerV1.process(request, response);
    }
}
