<%@ page contentType="text/html;charset=utf-8" language="java" %><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
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
    var svcCouponImgCodeJson = JSON.parse('${codeMapJsonObj['SVC_COUPON_IMG']}');

    $(document).ready(function () {
      // AUIGrid 생성
      var scopeText = '${inputParam.scope_text}';
      if (scopeText === "") {
        $('#scope_text_area').hide()
      } else {
        $('#scope_text_area').show()
      }

      onChangeImageCd('${inputParam.svc_coupon_img_cd}');
    });

    function onChangeImageCd(value) {
      var image = svcCouponImgCodeJson?.filter(item => item.code_value === value)?.[0];
      if (image) {
        var src = "../.." + image.code_v1;
        $('#img_area').attr('src', src);
      }
    }

    function onInputCouponName(value) {
      $('#svc_disp_coupon_name_area').text(value);
    }

    function onInputScopeText(value) {
      if (value === "") {
        $('#scope_text_area').hide()
      } else {
        $('#scope_text_area').show()
        $('#scope_text_area').text('포함범위 : ' + value);
      }
      // $('#scope_text_area').text(value);
    }

    // 닫기
    function fnClose() {
      window.close();
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
    <span class="title">쿠폰정보</span>
  </div>
  <div class="right">
    <button class="icon-home-black-lg">
      <span class="visually-hidden">홈으로 이동</span>
    </button>
  </div>
</div>
<!-- /sub header -->

<!-- sub top 고정영역 -->
<div class="sub-top-fixed-area">
  <!-- 탭영역 -->
  <div class="tabs" style="height: 100%">
    <div class="tab-list-wrap">
      <ul class="tab-list full"> <!-- full클래스 유무로 탭스타일 수정 -->
        <li>
          <a href="#" class="">
            <span>할인쿠폰</span>
          </a>
        </li>
        <li>
          <a href="#" class="active">
            <span>서비스쿠폰</span>
          </a>
        </li>
      </ul>
    </div>
  </div>
  <!-- /탭영역 -->
</div>
<!-- /sub top 고정영역 -->

<!-- sub content -->
<div class="sub-content" style="padding-top: 6.225rem;"> <!-- padding-top값은 동적계산 -->

  <div class="p-content-common pb-0">
    <div class="boxing bg-gray-gradient mileage-sum-wrap">
      <div class="mileage-sum">
        <div class="left">
          <div>
            <strong>홍길동</strong>
            <span>고객님 총 사용가능 서비스 쿠폰</span>
          </div>
        </div>
        <div class="right">
          <span class="num">3</span>
          <span class="text-gray">개</span>
        </div>
      </div>
    </div>
  </div>

  <div class="p-content-common">
    <div class="coupon-group">
      <img src="../../../static/img/cust/coupon/coupon-engine-oil-dfp.png" alt="" id="img_area">
      <div class="coupon-title" id="svc_disp_coupon_name_area">${inputParam.svc_disp_coupon_name}</div>
      <div class="info-wrap">
        <div id="">VIO-17</div>
        <div>1234512345</div>
        <div>2999-01-01 ~ 2999-01-01</div>
      </div>
      <div class="coverage" id="scope_text_area">포함범위 : ${inputParam.scope_text}</div>
      <div class="qr-wrap">
        <div class="qr-group">
          <div class="qr-img">
            <img src="../../../static/img/cust/coupon/qr-code-sample.png" alt="">
          </div>
          <div class="qr-number">QR0000-000000</div>
        </div>
      </div>
    </div>
  </div>

  <div class="p-content-common">
    <input class="form-control" id="svc_disp_coupon_name" placeholder="쿠폰표기명"
           oninput="javascript:onInputCouponName(this.value)" value="${inputParam.svc_disp_coupon_name}"/>
    
    <input class="form-control mt-6" id="scope_text" placeholder="포함범위" oninput="javascript:onInputScopeText(this.value)"
           value="${inputParam.scope_text}"/>

    <select class="form-select mt-6" id="svc_coupon_img_cd" name="svc_coupon_img_cd"
            onchange="javascript:onChangeImageCd(this.value)" alt="이미지테마">
      <c:forEach items="${codeMap['SVC_COUPON_IMG']}" var="item">
        <option value="${item.code_value}"
                <c:if
                  test="${inputParam.svc_coupon_img_cd eq item.code_value}">selected</c:if> >${item.code_name}</option>
      </c:forEach>
    </select>
  </div>
</div>
<!-- /sub content -->

<!-- bottom-tabs -->
<div class="bottom-tabs-wrap">
  <div class="bottom-tab">
    <i class="icon-bottom-tab-home active"></i>
    <span>홈</span>
  </div>
  <div class="bottom-tab">
    <i class="icon-bottom-tab-my"></i>
    <span>내차정보</span>
  </div>
  <div class="bottom-tab">
    <i class="icon-bottom-tab-heart"></i>
    <span>관심목록</span>
  </div>
  <div class="bottom-tab">
    <i class="icon-bottom-tab-cart"></i>
    <span>장바구니</span>
  </div>
  <div class="bottom-tab">
    <i class="icon-bottom-tab-menu"></i>
    <span>메뉴</span>
  </div>
</div>
<!-- /bottom-tabs -->

</body>

