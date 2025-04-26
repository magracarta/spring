package hello.servlet.web.frontcontroller.v5;

import hello.servlet.web.frontcontroller.ModelView;
import hello.servlet.web.frontcontroller.MyView;
import hello.servlet.web.frontcontroller.v3.controller.MemberFormControllerVV3;
import hello.servlet.web.frontcontroller.v3.controller.MemberListControllerVV3;
import hello.servlet.web.frontcontroller.v3.controller.MemberSaveControllerVV3;
import hello.servlet.web.frontcontroller.v4.controller.MemberFormControllerV4;
import hello.servlet.web.frontcontroller.v4.controller.MemberListControllerV4;
import hello.servlet.web.frontcontroller.v4.controller.MemberSaveControllerV4;
import hello.servlet.web.frontcontroller.v5.adaptor.ControllerV3HandlerAdapter;
import hello.servlet.web.frontcontroller.v5.adaptor.ControllerV4HandlerAdapter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(name = "frontControllerServiceV5" , urlPatterns = "/front-controller/v5/*")
public class FrontControllerServiceV5 extends HttpServlet {
    private final Map<String,Object> handlerMappingMap = new HashMap<>();
    private final List<MyHandlerAdapter> handlerAdapters = new ArrayList<>();

    public FrontControllerServiceV5() {
        initHandlerMappingMap();
        initHandelrAdapters();
    }

    private void initHandelrAdapters() {
        handlerAdapters.add(new ControllerV3HandlerAdapter());
        handlerAdapters.add(new ControllerV4HandlerAdapter());
    }

    private void initHandlerMappingMap() {
        handlerMappingMap.put("/front-controller/v5/v3/members/new-form", new MemberFormControllerVV3());
        handlerMappingMap.put("/front-controller/v5/v3/members/save", new MemberSaveControllerVV3());
        handlerMappingMap.put("/front-controller/v5/v3/members", new MemberListControllerVV3());

        //v4 추가
        handlerMappingMap.put("/front-controller/v5/v4/members/new-form", new MemberFormControllerV4());
        handlerMappingMap.put("/front-controller/v5/v4/members/save", new MemberSaveControllerV4());
        handlerMappingMap.put("/front-controller/v5/v4/members", new MemberListControllerV4());
    }


    @Override
    protected void service(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Object handler = getHandler(request);
        if(handler == null){
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            return;
        };

        MyHandlerAdapter adaptor = (MyHandlerAdapter) getHandlerAdaptor(handler);

        ModelView mv = adaptor.handle(request, response, handler);

        String viewName = mv.getViewName();//논리이름 new-form
        MyView view = viewResolver(viewName);

        view.render(mv.getModel(), request, response);
    }

    private Object getHandlerAdaptor(Object handler) {
        for (MyHandlerAdapter adapter : handlerAdapters) {
            if(adapter.supports(handler)){
               return adapter;
            }
        }
        throw  new IllegalArgumentException("handler adapter를 찾을수 없습니다. handler="+ handler);
    }

    private Object getHandler(HttpServletRequest request) {
        String requestURI = request.getRequestURI();
        return handlerMappingMap.get(requestURI);
    }

    private static MyView viewResolver(String viewName) {
        return new MyView("/WEB-INF/VIEW/" + viewName + ".jsp");
    }
}
