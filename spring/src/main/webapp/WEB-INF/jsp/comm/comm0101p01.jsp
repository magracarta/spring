<%@ page contentType="text/html;charset=utf-8" language="java" %>
<jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 기준정보 > 조직관리 > 전국센터 미리보기
-- 작성자 : 정재호
-- 최초 작성일 : 2024-01-22 00:00
------------------------------------------------------------------------------------------------------------------%>

<!DOCTYPE html>
<head>
  <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
  <link rel="stylesheet" href="/static/css/yk-mobile-customer.css">
  <script type="text/javascript">
    // 닫기
    function fnClose() {
      window.close();
    }

    function onChangeLeft(value) {
      $('#pin').css('left', Number(value) + "vw");
    }

    function onChangeTop(value) {
      $('#pin').css('top', Number(value) + "vw");
    }

  </script>
</head>

<body>
<!-- sub header -->
<div class="sub-top-header">
  <div class="left">
    <button class="icon-prev-black-lg">
      <span class="visually-hidden">이전페이지로 이동</span>
    </button>
    <span class="title">전국센터소개</span>
  </div>
  <div class="right">
    <button class="icon-home-black-lg">
      <span class="visually-hidden">홈으로 이동</span>
    </button>
  </div>
</div>
<!-- /sub header -->

<!-- sub content -->
<div class="sub-content"> <!-- padding-top값은 동적계산 -->
  <div class="p-content-common">
    전국 모든 서비스센터에서 신차상담/렌탈상담/서비스문의/부품구매가 가능합니다.
    <div style="display: flex; justify-content: space-around">
      <div>
        <span>left</span>
        <input type="text" class="form-control width140px" name="pos_left" id="pos_left"
               oninput="onChangeLeft(this.value)" value="${inputParam.left}"/>
      </div>
      <div>
        <span>top</span>
        <input type="text" class="form-control width140px" id="pos_top" name="pos_top" oninput="onChangeTop(this.value)"
               value="${inputParam.top}"/>
      </div>
    </div>
  </div>
  <div class="map-wrap">
    <div class="map">
      <button class="btn-center-location" style="left: ${inputParam.left}vw; top: ${inputParam.top}vw" id="pin">
        <c:if test="${inputParam.pos_lr eq 'L'}">
          ${inputParam.org_name}
          <i class="icon-center-pin" style="margin-left: 0.25rem; margin-right: 0"></i>
        </c:if>

        <c:if test="${inputParam.pos_lr ne 'L'}">
          <i class="icon-center-pin"></i>
          ${inputParam.org_name}
        </c:if>
      </button>
    </div>
  </div>
</div>
<!-- /sub content -->

<!-- bottom-tabs -->
<div class="bottom-tabs-wrap">
  <div class="bottom-tab">
    <i class="icon-bottom-tab-home "></i>
    <span>홈</span>
  </div>
  <div class="bottom-tab">
    <i class="icon-bottom-tab-my "></i>
    <span>내차정보</span>
  </div>
  <div class="bottom-tab">
    <i class="icon-bottom-tab-heart "></i>
    <span>관심목록</span>
  </div>
  <div class="bottom-tab">
    <i class="icon-bottom-tab-cart"></i>
    <span>장바구니</span>
  </div>
  <div class="bottom-tab">
    <i class="icon-bottom-tab-menu "></i>
    <span>메뉴</span>
  </div>
</div>
<!-- /bottom-tabs -->

</body>

