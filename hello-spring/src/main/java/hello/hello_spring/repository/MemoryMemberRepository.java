package hello.hello_spring.repository;

// 필요한 클래스들을 import합니다.
import hello.hello_spring.domain.Member;
import org.springframework.stereotype.Repository;

import java.util.*;

public class MemoryMemberRepository implements MemberRepository {
    // 회원 정보를 저장할 Map 객체와 회원 ID를 생성하기 위한 시퀀스를 정의합니다.
    private static Map<Long, Member> store = new HashMap<>();
    private static long sequence = 0L;

    // 회원 정보를 저장하는 메소드입니다.
    public Member save(Member member) {
        // 회원 ID를 생성하고, member 객체에 설정합니다.
        member.setId(++sequence);
        // 생성된 ID를 키로 하여 member 객체를 store(Map)에 저장합니다.
        store.put(member.getId(), member);
        // 저장된 member 객체를 반환합니다.
        return member;
    }

    // ID로 회원 정보를 찾는 메소드입니다.
    @Override
    public Optional<Member> findById(Long id) {
        // ID를 키로 하여 store(Map)에서 회원 정보를 찾아 반환합니다.
        // Optional.ofNullable을 사용하여 null일 경우에도 Optional 객체로 감싸서 반환합니다.
        return Optional.ofNullable(store.get(id));
    }

    // 이름으로 회원 정보를 찾는 메소드입니다.
    @Override
    public Optional<Member> findByName(String name) {
        // store(Map)에 저장된 모든 회원 정보를 스트림으로 변환하여
        // 이름이 일치하는 회원을 찾습니다.
        return store.values().stream()
                .filter(member -> member.getName().equals(name)) // 이름이 일치하는지 필터링
                .findAny(); // 일치하는 첫 번째 회원을 반환
    }

    // 모든 회원 정보를 반환하는 메소드입니다.
    @Override
    public List<Member> findAll() {
        // store(Map)에 저장된 모든 회원 정보를 새로운 ArrayList로 변환하여 반환합니다.
        return new ArrayList<>(store.values());
    }

    public void clearStore(){
        store.clear();
    }
}
