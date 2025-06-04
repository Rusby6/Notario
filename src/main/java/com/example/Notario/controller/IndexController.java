package com.example.Notario.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class IndexController {

    @GetMapping("/esp")
    public String index1() {

        return "esp";
    }

    @GetMapping("/extr")
    public String index2() {

        return "extr";
    }
}