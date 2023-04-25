package com.moham.coursemores.repository;

import com.moham.coursemores.domain.Interest;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface InterestRepository extends JpaRepository<Interest, Integer> {

    List<Interest> findByUserIdAndFlag(int userId, boolean flag);

    Optional<Interest> findByUserIdAndCourseId(int userId, int courseId);

}