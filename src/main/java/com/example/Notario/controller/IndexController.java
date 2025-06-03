package com.example.Notario.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class IndexController {

    @GetMapping("/español")
    public String index1() {

        return "index1";
    }

    @GetMapping("/extranjero")
    public String index2() {

        return "index2";
    }
}