<%@ page contentType="text/html;charset=utf-8" language="java" %><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 고객현황 > 고객조회/등록 > 쿠폰사용내역 팝업
-- 작성자 : 정재호
-- 최초 작성일 : 2024-02-06 00:00:00
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
  <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
  <script type="text/javascript">
    var tab_id;

    var tabLoad = [false, false];

    function fnLoadFrame(num) {
      tabLoad[num] = true;
    }

    $(document).ready(function () {
      $('ul.tabs-c li a').click(function () {
        tab_id = $(this).attr('data-tab');

        // 아이프레임이 로드됬는지 확인함
        var tabNum = tab_id.substr(5, 1);
        console.log(tabNum);
        if (tabLoad[tabNum - 1] == false) {
          alert("잠시만 기다려주세요.");
          console.error(tabNum, "아이프레임이 아직 로드안됨 =>", tabLoad);
          return false;
        }

        if (tab_id == 'inner1' || tab_id == undefined) {
          iframe = document.getElementById("contentFrame1");
        } else if (tab_id == 'inner2') {
          iframe = document.getElementById("contentFrame2");
        }

        if (iframe.contentWindow.createAUIGrid) {
          iframe.contentWindow.createAUIGrid();
        }
        if (iframe.contentWindow.goSearch) {
          iframe.contentWindow.goSearch();
        }

        $('ul.tabs-c li a').removeClass('active');
        $('.tabs-inner').removeClass('active');

        $(this).addClass('active');
        $("#" + tab_id).addClass('active');
      });
    });
  </script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
  <div class="popup-wrap width-100per">
    <div class="main-title">
      <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
    </div>
    <div class="content-wrap">
      <div class="">
        <!-- 메인 타이틀 -->
        <!-- 탭 -->
        <ul class="tabs-c">
          <li class="tabs-item">
            <a href="#" class="tabs-link font-12 active" data-tab="inner1">할인쿠폰조회</a>
          </li>
          <li class="tabs-item">
            <a href="#" class="tabs-link font-12" data-tab="inner2">서비스쿠폰조회</a>
          </li>
        </ul>
        <!-- /탭 -->

        <!-- /메인 타이틀 -->

        <div id="inner1" class="tabs-inner active" style="height: 360px;">
          <iframe src="/cust/cust0102p04?cust_no=${inputParam.cust_no}" style="width:100%; height: 100%;"
                  id="contentFrame1" name="contentFrame" frameborder="0" scrolling="no"
                  onload="fnLoadFrame(0)"></iframe>
        </div>
        <div id="inner2" class="tabs-inner " style="height: 360px;">
          <iframe src="/cust/cust0102p05?cust_no=${inputParam.cust_no}" id="contentFrame2" name="contentFrame"
                  frameborder="0" style="width:100%; height: 100%;" scrolling="no" onload="fnLoadFrame(1)"></iframe>
        </div>
      </div>
      <jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
    </div>
  </div>
</form>
</body>
</html>