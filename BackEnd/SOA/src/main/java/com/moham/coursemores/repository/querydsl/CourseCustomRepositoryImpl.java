package com.moham.coursemores.repository.querydsl;

import static com.moham.coursemores.domain.QCourse.course;
import static com.moham.coursemores.domain.QCourseLocation.courseLocation;
import static com.moham.coursemores.domain.QRegion.region;
import static com.moham.coursemores.domain.QHashtag.hashtag;

import com.moham.coursemores.domain.Course;
import com.moham.coursemores.domain.CourseLocation;
import com.moham.coursemores.domain.Hashtag;
import com.moham.coursemores.domain.Region;
import com.querydsl.core.types.Order;
import com.querydsl.core.types.OrderSpecifier;
import com.querydsl.core.types.dsl.BooleanExpression;
import com.querydsl.core.types.dsl.PathBuilder;
import com.querydsl.jpa.JPQLQuery;
import com.querydsl.jpa.impl.JPAQueryFactory;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.support.PageableExecutionUtils;
import org.springframework.stereotype.Repository;

@Repository
@RequiredArgsConstructor
public class CourseCustomRepositoryImpl implements CourseCustomRepository {

    private final JPAQueryFactory jpaQueryFactory;
    private static final String ALL = "전체";

    @Override
    public Page<Course> searchAll(String word, Long regionId, List<Long> themeIds, int isVisited, Pageable pageable) {
        List<Course> fetch = jpaQueryFactory
                .selectFrom(course)
                .distinct()
                .where(wordContain(word),
                        regionEq(regionId),
                        themeContain(themeIds),
                        isVisited(isVisited),
                        isNotDelete())
                .offset(pageable.getOffset())
                .limit(pageable.getPageSize())
                .orderBy(getOrderSpecifier(pageable.getSort()).toArray(OrderSpecifier[]::new))
                .fetch();

        //count 만 가져오는 쿼리
        JPQLQuery<Course> count = jpaQueryFactory
                .selectFrom(course)
                .distinct()
                .where(wordContain(word),
                        regionEq(regionId),
                        themeContain(themeIds),
                        isVisited(isVisited),
                        isNotDelete());

        return PageableExecutionUtils.getPage(fetch, pageable, count::fetchCount);
    }

    @Override
    public Map<String, List<Integer>> testES() {
        String value = "%싸피%";

        Map<String, List<Integer>> result = new HashMap<>();

        jpaQueryFactory
            .selectFrom(course)
            .distinct()
            .where(course.title.like(value))
            .fetch()
            .forEach(o->{
                if(result.containsKey(o.getTitle())){
                    List<Integer> existList = result.get(o.getTitle());
                    existList.add(1);
                    result.put(o.getTitle(), existList);
                }
                else{
                    result.put(o.getTitle(), new ArrayList<>(List.of(1)));
                }
            });

        jpaQueryFactory
                .selectFrom(courseLocation)
                .distinct()
                .where(courseLocation.name.like(value))
                .fetch()
                .forEach(o->{
                    if(result.containsKey(o.getName())){
                        List<Integer> existList = result.get(o.getName());
                        existList.add(2);
                        result.put(o.getName(), existList);
                    }
                    else{
                        result.put(o.getName(), new ArrayList<>(List.of(2)));
                    }
                });


        jpaQueryFactory
                .selectFrom(hashtag)
                .distinct()
                .where(hashtag.name.like(value))
                .fetch()
                .forEach(o->{
                    if(result.containsKey(o.getName())){
                        List<Integer> existList = result.get(o.getName());
                        existList.add(3);
                        result.put(o.getName(), existList);
                    }
                    else{
                        result.put(o.getName(), new ArrayList<>(List.of(3)));
                    }
                });

        return result;
    }

    // 동적 정렬
    private List<OrderSpecifier> getOrderSpecifier(Sort sort) {
        return sort
                .stream()
                .map(order -> {
                    Order direction = order.isAscending() ? Order.ASC : Order.DESC;
                    String prop = order.getProperty();
                    PathBuilder orderByExpression = new PathBuilder(Course.class, "course");

                    return new OrderSpecifier(direction, orderByExpression.get(prop));
                })
                .collect(Collectors.toList());
    }

    private BooleanExpression isNotDelete() {
        return course.deleteTime.isNull();
    }

    private BooleanExpression wordContain(String word) {
        return (word != null && !word.isBlank()) ?
                course.title.contains(word)
                        .or(course.courseHashtagList.any().hashtag.name.contains(word))
                        .or(course.courseLocationList.any().name.contains(word)) :
                null;
    }

    private BooleanExpression regionEq(Long regionId) {
        if (regionId == null || regionId == 0)
            return null;

        Region temp = jpaQueryFactory
                .selectFrom(region)
                .where(region.id.eq(regionId))
                .fetchOne();

        if (temp == null || ALL.equals(temp.getSido())) {
            return null;
        } else if (ALL.equals(temp.getGugun())) {
            return course.sido.eq(temp.getSido());
        } else {
            return course.gugun.eq(temp.getGugun());
        }
    }

    private BooleanExpression themeContain(List<Long> themeIds) {
        return (themeIds != null && !themeIds.isEmpty() && themeIds.get(0) != 0) ?
                course.themeOfCourseList.any().theme.id.in(themeIds) :
                null;
    }

    private BooleanExpression isVisited(int isVisited) {
        return isVisited == 1 ?
                course.visited.eq(true) :
                null;
    }

}