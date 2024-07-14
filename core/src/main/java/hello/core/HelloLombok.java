package hello.core;

import lombok.*;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@ToString
public class HelloLombok {
    private String name;
    private int age;

    public static void main(String[] args) {
        HelloLombok helloLombok = new HelloLombok();
        System.out.println(helloLombok.getName());
        System.out.println(helloLombok.getAge());
        System.out.println(helloLombok);
    }
}
