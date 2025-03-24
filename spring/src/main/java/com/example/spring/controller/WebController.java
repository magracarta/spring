package com.example.spring.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class WebController {

    @GetMapping("/main")
    public String index() {
        return "SpringMain";
    }

    @RequestMapping("/home")
    public String home() {
        return "SpringHome";
    }
}
