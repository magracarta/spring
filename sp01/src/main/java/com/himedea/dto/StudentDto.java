package com.himedea.dto;


import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class StudentDto {
    private String sNum;
    private String sId;
    private String sPw;
    private String sName;
    private int sAge;
    private String sGender;
    private String sMajor;

}
