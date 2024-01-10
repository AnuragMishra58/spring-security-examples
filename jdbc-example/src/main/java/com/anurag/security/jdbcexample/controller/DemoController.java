package com.anurag.security.jdbcexample.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class DemoController {
    @GetMapping("/home")
    public String welcome(){
        return "Hi there!";
    }

    @GetMapping("/customer")
    public String customer(){
        return "Hi customer!";
    }
}
