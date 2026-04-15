package com.example.feedback.dto;

public class CustomerDto {

    private Long id;
    private String username;
    private String fullName;
    private String email;
    private String tel;
    private Integer status;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getTel() { return tel; }
    public void setTel(String tel) { this.tel = tel; }

    public Integer getStatus() { return status; }
    public void setStatus(Integer status) { this.status = status; }
}
