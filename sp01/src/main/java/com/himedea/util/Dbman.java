package com.himedea.util;


import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class Dbman {
    private String driver;
    private String url;
    private String id;
    private String pw;

}
