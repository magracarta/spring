package hello.hello_spring.repository;

import hello.hello_spring.domain.Member;
import org.springframework.jdbc.datasource.DataSourceUtils;

import javax.sql.DataSource;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class JdbcMemberRepository implements MemberRepository {
    private final DataSource dataSource;

    public JdbcMemberRepository(DataSource dataSource) {
        this.dataSource = dataSource;
    }
    private Connection getConnection() {
        return DataSourceUtils.getConnection(dataSource);
    }
    private void  closeConnection(Connection con){
        DataSourceUtils.releaseConnection(con, dataSource);
    }

    @Override
    public Member save(Member member) {
        String sql = "insert into member (name) values(?)";
        Connection con = getConnection();
        try ( PreparedStatement pstmt = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS) ) {
            pstmt.setString(1, member.getName());
            pstmt.executeUpdate();

            try (ResultSet rs = pstmt.getGeneratedKeys()){
                if (rs.next())  member.setId(rs.getLong(1));
                else throw  new SQLException("id 조회 실패");
            }
            return  member;
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }finally {
            closeConnection(con);
        }
    }

    @Override
    public Optional<Member> findById(Long id) {
        String sql = "select * from member where id = ?";
        Connection con = getConnection();
        try(PreparedStatement pstmt = con.prepareStatement(sql)) {
            pstmt.setLong(1,id);
            return selectFunction(pstmt);
        } catch (SQLException e) {
            throw new IllegalStateException(e);
        }finally {
            closeConnection(con);
        }
    }

    @Override
    public Optional<Member> findByName(String name) {
        String sql = "select * from member where name = ?";
        Connection con = getConnection();
        try(PreparedStatement pstmt = con.prepareStatement(sql)) {
            pstmt.setString(1,name);
            return selectFunction(pstmt);
        } catch (SQLException e) {
            throw new IllegalStateException(e);
        }finally {
            closeConnection(con);
        }
    }

    @Override
    public List<Member> findAll() {
        List<Member> list = new ArrayList<>();
        String sql = "select * from member";
        Connection con = getConnection();
        try(PreparedStatement pstmt = con.prepareStatement(sql);
            ResultSet rs = pstmt.executeQuery() ){

            while (rs.next()){
                Member member = new Member();
                member.setId(rs.getLong("id"));
                member.setName(rs.getString("name"));
                list.add(member);
            }
        }catch (SQLException e){
            throw new IllegalStateException(e);
        }finally {
            closeConnection(con);
        }
        return list;
    }


    public Optional<Member> selectFunction(PreparedStatement pstmt ) throws SQLException {
        try(ResultSet rs = pstmt.executeQuery()) {
            if(rs.next()){
                Member member = new Member();
                member.setId(rs.getLong("id"));
                member.setName(rs.getString("name"));
                return Optional.of(member);
            }else {
                return Optional.empty();
            }
        }
    }


}
