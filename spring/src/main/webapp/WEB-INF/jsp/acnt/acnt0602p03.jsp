<%@ page contentType="text/html;charset=utf-8" language="java" %>
<jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 자산 > 휴가원관리 > null > 연차쪽지 리스트 팝업
-- 작성자 : 정재호
-- 최초 작성일 : 2024-04-14
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
  <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
  <script type="text/javascript">
    $(document).ready(function () {
      createAUIGrid();
    });

    function createAUIGrid() {
      var gridPros = {
        rowIdField: "_$uid",
        showRowNumColumn: true,
      };
      var columnLayout = [
        {
          dataField: "holiday_year",
          visible: false
        },
        {
          dataField: "mem_no",
          visible: false
        },
        {
          headerText: "이름",
          dataField: "kor_name",
          width: '70'
        },
        {
          headerText: "종류",
          dataField: "paper_type",
          width: '70'
        },
        {
          headerText: "보낸일시",
          dataField: "send_date",
          width: '170'
        },
        {
          headerText: "내용",
          dataField: "paper_contents",
        },
      ];

      auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
      AUIGrid.setGridData(auiGrid, ${list});
      $("#auiGrid").resize();

      // 휴가원 상세
      AUIGrid.bind(auiGrid, "cellClick", function (event) {
        if (event.dataField == "holiday_type_name") {
          var param = {
            "mem_holiday_seq": event.item.mem_holiday_seq,
          };
          var popupOption = "scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1350, height=470, left=0, top=0";
          $M.goNextPage("/mmyy/mmyy0106p02", $M.toGetParam(param), {popupStatus: popupOption});
        }
      });

    }

    function fnClose() {
      window.close();
    }
  </script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
  <div class="popup-wrap width-100per">
    <div class="main-title">
      <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
    </div>
    <div class="content-wrap">
      <div id="auiGrid" style="margin-top: 5px; height: 300px;"></div>
      <div class="btn-group mt10">
        <div class="right">
          <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
            <jsp:param name="pos" value="BOM_R"/>
          </jsp:include>
        </div>
      </div>
    </div>
  </div>
</form>
</body>
</html>