package com.anurag.security.jdbcexample.repository;

import com.anurag.security.jdbcexample.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserRepository extends JpaRepository<User, String> {
}
