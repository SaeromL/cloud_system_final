package com.example.demo;

public class Task {
    private int id;
    private String description;
    private String status;

    public Task(int id, String description, String status) {
        this.id = id;
        this.description = description;
        this.status = status;
    }

    public int getId() { return id; }
    public String getDescription() { return description; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
