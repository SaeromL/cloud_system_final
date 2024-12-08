package com.example.demo;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;

@Controller
public class TaskController {
    private List<Task> tasks = new ArrayList<>();
    private int nextId = 1;

    @GetMapping("/tasks")
    public String getTasks(Model model) {
        model.addAttribute("tasks", tasks);
        return "index";
    }

    @PostMapping("/tasks")
    public String addTask(@RequestParam String description, Model model) {
        tasks.add(new Task(nextId++, description, "Pending"));
        return "redirect:/tasks";
    }

    @PostMapping("/tasks/{id}")
    public String updateTaskStatus(@PathVariable int id, @RequestParam String status) {
        for (Task task : tasks) {
            if (task.getId() == id) {
                task.setStatus(status);
                break;
            }
        }
        return "redirect:/tasks";
    }
    
    @PostMapping("/tasks/delete/{id}")
    public String deleteTask(@PathVariable int id) {
        tasks.removeIf(task -> task.getId() == id); // Remove task by ID
        return "redirect:/tasks";
    }

}
