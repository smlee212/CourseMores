package com.moham.coursemores.repository;

import com.moham.coursemores.domain.ThemeOfCourse;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ThemeOfCourseRepository extends JpaRepository<ThemeOfCourse, Integer> {
    List<ThemeOfCourse> findByCourseId(int CourseId);
}
