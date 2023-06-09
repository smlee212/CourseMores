package com.moham.coursemores.domain;

import com.moham.coursemores.domain.time.UpdateTimeEntity;
import com.moham.coursemores.dto.course.LocationUpdateReqDto;
import java.util.List;
import javax.persistence.CascadeType;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.OneToMany;
import javax.persistence.OneToOne;
import javax.persistence.Table;
import javax.validation.constraints.NotNull;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.ToString;

@Entity
@Table(name = "course_location")
@Getter
@ToString
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class CourseLocation extends UpdateTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "course_location_id")
    private Long id;

    @NotNull
    private String name;

    @Column(length = 50)
    private String title;

    @Column(length = 5000)
    private String content;

    @NotNull
    @Column(length = 1000)
    private String roadViewImage;

    @NotNull
    @Column
    private double latitude;

    @NotNull
    @Column
    private double longitude;

    @NotNull
    @OneToOne(targetEntity = Region.class, fetch = FetchType.LAZY)
    @JoinColumn(name = "region_id")
    private Region region;

    @NotNull
    @ManyToOne(targetEntity = Course.class, fetch = FetchType.LAZY)
    @JoinColumn(name = "course_id")
    private Course course;

    @OneToMany(mappedBy = "courseLocation", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<CourseLocationImage> courseLocationImageList;

    @Builder
    public CourseLocation(String name,
            String title,
            String content,
            String roadViewImage,
            double latitude,
            double longitude,
            Region region,
            Course course) {
        this.name = name;
        this.title = title;
        this.content = content;
        this.roadViewImage = roadViewImage;
        this.latitude = latitude;
        this.longitude = longitude;
        this.region = region;
        this.course = course;
    }

    public void update(LocationUpdateReqDto locationUpdateReqDto) {
        this.name = locationUpdateReqDto.getName();
        this.title = locationUpdateReqDto.getTitle();
        this.content = locationUpdateReqDto.getContent();
    }

}