<%@ page contentType="text/html;charset=utf-8" language="java" %><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 메인 > 문자발송 > null > 단체발송 엑셀업로드
-- 작성자 : 정재호
-- 최초 작성일 : 2024-05-17
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
  <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
  <script type="text/javascript">
    var hpRegex = /^(?:(010-?\d{4})|(01[1|6|7|8|9]-?\d{3,4}))-?(\d{4})$/;
    var auiGrid;

    $(document).ready(function () {
      createAUIGrid();
    });

    function createAUIGrid() {
      var gridProps = {
        rowIdField: "_$uid",
        noDataMessage: "엑셀에서 데이터를 복사(Ctrl+C) 하여 이곳에 붙여 넣기(Ctrl+V) 하십시오.",
        showAutoNoDataMessage: true, // 데이터 없을 때 메세지 노출 여부
        editable: true, // 수정 모드
        enableRestore: false
      };

      var columnLayout = [
        {
          headerText: "이름",
          dataField: "name",
          style: "aui-center",
          editable: false,
        },
        {
          headerText: "전화번호",
          dataField: "hp_no",
          style: "aui-center",
          editable: false,
        },
        {
          headerText: "적합여부",
          dataField: "is_check_text",
          style: "aui-center",
          editable: false,
        },
        {
          dataField: "is_check",
          visible: false
        },
      ];

      auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridProps);
      AUIGrid.setGridData(auiGrid, []);

      // 붙여넣기 후 처리 이벤트
      AUIGrid.bind(auiGrid, "pasteEnd", function (event) {
        pasteEndCheckGridData();
      });

      $("#auiGrid").resize();
    }

    // 데이터 적합 검사
    function pasteEndCheckGridData() {
      var gridData = AUIGrid.getGridData(auiGrid);
      gridData.map((item, idx) => {
        if (item.name === "") {
          updateRow(item, "이름이 없습니다.", false, idx);
          return;
        }

        if (item.hp_no === "") {
          updateRow(item, "휴대폰번호가 없습니다.", false, idx);
          return;
        }

        if (!hpRegex.test(item.hp_no)) {
          updateRow(item, "올바른 휴대폰번호가 아닙니다.", false, idx);
          return;
        }

        updateRow(item, "적합", true, idx);
      })
    }

    // row 업데이트 함수
    function updateRow(item, text, isCheck, idx) {
      item.is_check_text = text;
      item.is_check = isCheck;
      AUIGrid.updateRow(auiGrid, item, idx);
    }

    // 반영 버튼
    function fnConfirm() {
      var gridData = AUIGrid.getGridData(auiGrid);
      if (gridData.length == 0) {
        alert('데이터가 없습니다.');
        return;
      }

      <c:if test="${not empty inputParam.parent_js_name}">
      try {
        if (confirm("반영하시겠습니까?") == false) {
          return false;
        }
        
        var result = [];
        gridData.map(item => {
          // 적합 상태 데이터만 전달
          if (item.is_check) {
            result.push(item);
          }
        })

        opener.${inputParam.parent_js_name}(result);
        window.close();
      } catch (e) {
        console.log(e);
        alert('호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.');
      }
      </c:if>
    }

    // 닫기 버튼
    function fnClose() {
      window.close();
    }

    // 초기화 버튼
    function fnResetGrid() {
      AUIGrid.clearGridData(auiGrid);
    }


  </script>
</head>
<body>
<form id="main_form" name="main_form">
  <!-- 팝업 -->
  <div class="popup-wrap width-100per">
    <!-- 타이틀영역 -->
    <div class="main-title">
      <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
    </div>
    <!-- /타이틀영역 -->
    <div class="content-wrap">
      <div class="col-12 boxing-body">
        <div class="btn-group">
          <div class="right">
            <button type="button" class="btn btn-info" onclick="fnResetGrid();">초기화</button>
          </div>
        </div>
        <div id="auiGrid" style="margin-top: 5px; height: 450px;"></div>
      </div>

      <!-- 그리드 서머리, 컨트롤 영역 -->
      <div class="btn-group mt10">
        <div class="right">
          <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
            <jsp:param name="pos" value="BOM_R"/>
          </jsp:include>
        </div>
      </div>
      <!-- /그리드 서머리, 컨트롤 영역 -->
    </div>
  </div>
  <!-- /팝업 -->
</form>
</body>
</html>