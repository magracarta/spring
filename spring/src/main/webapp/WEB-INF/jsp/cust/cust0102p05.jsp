<%@ page contentType="text/html;charset=utf-8" language="java" %><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 고객현황 > 고객조회/등록 > 쿠폰사용내역 팝업 > 서비스쿠폰조회
-- 작성자 : 정재호
-- 최초 작성일 : 2024-02-06 00:00:00
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
  <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
  <script type="text/javascript">

    var auiGrid;

    $(document).ready(function () {
      createAUIGrid();
    });

    // 그리드생성
    function createAUIGrid() {
      var gridPros = {
        rowIdField: "_$uid",
        showRowNumColumn: true,
        enableFilter: true,
        editable: false,
      };
      // AUIGrid 칼럼 설정
      var columnLayout = [
        {
          dataField : "aui_status_cd",
          visible: false
        },
        {
          dataField: "cust_svc_coupon_no",
          visible: false
        },
        {
          dataField: "cust_no",
          visible: false
        },
        {
          headerText: "발행일자",
          dataField: "issue_dt",
          style: "aui-center",
          dataType: "date",
          dataInputString: "yy-mm-dd",
          formatString: "yy-mm-dd",
        },
        {
          headerText: "모델명",
          dataField: "machine_name",
          style: "aui-center",
        },
        {
          headerText: "차대번호",
          dataField: "body_no",
          style: "aui-center",
        },
        {
          headerText: "구분",
          dataField: "gubun_name",
          style: "aui-center",
        },
        {
          headerText: "쿠폰명",
          dataField: "coupon_name",
          style: "aui-center",
        },
        {
          headerText: "쿠폰표기명",
          dataField: "svc_disp_coupon_name",
          style: "aui-center",
        },
        {
          headerText: "사용일자",
          dataField: "apply_dt",
          style: "aui-center",
          dataType: "date",
          dataInputString: "yy-mm-dd",
          formatString: "yy-mm-dd",
        },
      ];

      auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros)
      AUIGrid.setGridData(auiGrid, ${list});
      $("#auiGrid").resize();
    }

  </script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
  <div id="auiGrid" style="margin-top: 5px; height: 350px;"></div>
  <div class="btn-group mt5">
    <div class="right">
      <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
        <jsp:param name="pos" value="BOM_R"/>
      </jsp:include>
    </div>
  </div>
</form>
</body>
</html>