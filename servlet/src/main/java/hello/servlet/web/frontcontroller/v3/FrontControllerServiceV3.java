package hello.servlet.web.frontcontroller.v3;

import hello.servlet.web.frontcontroller.ModelView;
import hello.servlet.web.frontcontroller.MyView;
import hello.servlet.web.frontcontroller.v3.controller.MemberFormControllerVV3;
import hello.servlet.web.frontcontroller.v3.controller.MemberListControllerVV3;
import hello.servlet.web.frontcontroller.v3.controller.MemberSaveControllerVV3;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@WebServlet(name = "frontControllerServiceV3" , urlPatterns = "/front-controller/v3/*")
public class FrontControllerServiceV3 extends HttpServlet {
    private Map<String, ControllerV3> controllerMap = new HashMap<>();

    public FrontControllerServiceV3() {
        controllerMap.put("/front-controller/v3/members/new-form", new MemberFormControllerVV3());
        controllerMap.put("/front-controller/v3/members/save", new MemberSaveControllerVV3());
        controllerMap.put("/front-controller/v3/members", new MemberListControllerVV3());
    }

    @Override
    protected void service(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("FrontControllerServiceV3::service");
        String requestURI = request.getRequestURI();

        ControllerV3 controllerV3 = controllerMap.get(requestURI);
        if(controllerV3 == null){
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            return;
        };

        Map<String, String> paramMap = createParamMap(request);
        ModelView mv = controllerV3.process(paramMap);

        String viewName = mv.getViewName();//논리이름 new-form
        MyView view = viewResolver(viewName);

        view.render(mv.getModel(), request, response);
    }

    private static MyView viewResolver(String viewName) {
        return new MyView("/WEB-INF/VIEW/" + viewName + ".jsp");
    }

    private static Map<String, String> createParamMap(HttpServletRequest request) {
        Map<String, String> paramMap = new HashMap<>();
        //ParamMap
        request.getParameterNames().asIterator()
                .forEachRemaining(paraName -> paramMap.put(paraName, request.getParameter(paraName)));
        return paramMap;
    }
}
