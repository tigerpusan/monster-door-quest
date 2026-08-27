# Monster Door Quest V0.6 Android Performance Checklist

실기기에서 아래를 확인합니다.

- [ ] 첫 터치 후 문 scale 반응이 체감상 즉시 시작한다 (목표 50ms 이내)
- [ ] 문 개방 핵심 애니메이션은 약 300ms
- [ ] 정답 시 flash + chime + hero dash가 끊김 없이 이어진다
- [ ] 오답 시 monster pop + boom/growl + screen shake가 즉시 느껴진다
- [ ] 10초 플레이 타이머가 정확히 동작한다
- [ ] 60fps에서 눈에 띄는 frame drop이 없다
- [ ] 첫 SFX 재생 지연이 없다 (preload 확인)
- [ ] BGM과 SFX 볼륨 밸런스가 플레이 판단을 방해하지 않는다
- [ ] Stage 3부터 시작한다
- [ ] Stage 5+에서 동일 방향 3연속이 발생하지 않는다
