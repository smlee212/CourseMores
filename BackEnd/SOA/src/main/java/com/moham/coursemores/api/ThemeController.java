package com.moham.coursemores.api;

import com.moham.coursemores.dto.theme.ThemeResDto;
import com.moham.coursemores.service.ThemeService;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("theme")
@RequiredArgsConstructor
public class ThemeController {

    private static final Logger logger = LoggerFactory.getLogger(ThemeController.class);

    private final ThemeService themeService;

    @GetMapping
    public ResponseEntity<Map<String, Object>> getThemeList() {
        logger.info(">> request : none");

        Map<String, Object> resultMap = new HashMap<>();

        List<ThemeResDto> themeList = themeService.getThemeList();
        resultMap.put("themeList",themeList);
        logger.info("<< response : themeList={}",themeList);

        return new ResponseEntity<>(resultMap, HttpStatus.OK);
    }
}
