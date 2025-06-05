package com.example.Notario.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;

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