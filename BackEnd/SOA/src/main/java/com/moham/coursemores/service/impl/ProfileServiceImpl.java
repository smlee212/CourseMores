package com.moham.coursemores.service.impl;


import com.moham.coursemores.domain.User;
import com.moham.coursemores.dto.profile.UserInfoResDto;
import com.moham.coursemores.dto.profile.UserInfoUpdateReqDto;
import com.moham.coursemores.repository.UserRepository;
import com.moham.coursemores.service.ProfileService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ProfileServiceImpl implements ProfileService {

    private final UserRepository userRepository;
    private final FileUploadService fileUploadService;

    @Override
    public UserInfoResDto getMyProfile(Long userId) {
        // userId의 User 가져오기
        User user = userRepository.findByIdAndDeleteTimeIsNull(userId)
                .orElseThrow(()-> new NullPointerException("해당 유저를 찾을 수 없습니다."));

        return UserInfoResDto.builder()
                .nickname(user.getNickname())
                .age(user.getAge())
                .gender(user.getGender())
                .profileImage(user.getProfileImage())
                .build();
    }

    @Override
    public void alramSetting(Long userId) {
        // 알람 셋팅
    }

    @Override
    @Transactional
    public void updateUserInfo(Long userId, UserInfoUpdateReqDto userInfoUpdateReqDto, MultipartFile profileImage) {
        // userId의 User 가져오기
        User user = userRepository.findByIdAndDeleteTimeIsNull(userId)
                .orElseThrow(()-> new NullPointerException("해당 유저를 찾을 수 없습니다."));

        String imageUrl = "default";
        if(profileImage != null)
            imageUrl = fileUploadService.uploadImage(profileImage);

        user.update(userInfoUpdateReqDto, imageUrl);
    }

    @Override
    @Transactional
    public void deleteUser(Long userId) {
        // userId의 User 가져오기
        User user = userRepository.findByIdAndDeleteTimeIsNull(userId)
                .orElseThrow(()-> new NullPointerException("해당 유저를 찾을 수 없습니다."));
        
        // deleteTime 추가
        user.delete();
    }
}