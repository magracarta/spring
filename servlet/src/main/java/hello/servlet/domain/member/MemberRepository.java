package hello.servlet.domain.member;

import lombok.Getter;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/*
* 동시성 문제가 고려되지 않음, 실무에서는 ConcurrentHashMap, AtomicLong 사용고려
* */
public class MemberRepository {
    private static Map<Long, Member> store = new HashMap<>();
    private static Long sequence = 0L;

    @Getter
    private static final MemberRepository instance = new MemberRepository();
    private MemberRepository() {}

    public Member save(Member member) {
        member.setId(++sequence);
        store.put(member.getId(), member);
        return member;
    }

    public Member findById(Long id) {
        return store.get(id);
    }

    public List<Member> findAll() {
        return new ArrayList<>(store.values());
    }

    public void clearStore() {
        store.clear();
    }
}
