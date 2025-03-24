<%@ page contentType="text/html;charset=utf-8" language="java" %><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 쿠폰관리 > 서비스 쿠폰관리 > null > null
-- [재호] - 3.4차 추가 개발 : 서비스 쿠폰 개편
-- 작성자 : 김상덕
-- 최초 작성일 : 2020-04-07 19:54:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
  <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
  <script type="text/javascript">
    <%-- 여기에 스크립트 넣어주세요. --%>

    var auiGrid;

    $(document).ready(function () {
      // AUIGrid 생성
      createAUIGrid();
      goSearch();
    });

    //그리드생성
    function createAUIGrid() {
      var gridPros = {
        // 정렬 가능여부
        enableSorting: false,
        showRowNumColumn: true,
        wrapSelectionMove: false,
        editable: false,
      };
      var columnLayout = [
        {
          headerText: "쿠폰번호",
          dataField: "svc_coupon_no",
          style: "aui-center",
          visible: false,
        },
        {
          headerText: "쿠폰명",
          dataField: "svc_coupon_name",
          style: "aui-center aui-popup",
        },
        {
          headerText: "쿠폰표기명",
          dataField: "svc_disp_coupon_name",
          style: "aui-center",
        },
        {
          headerText: "유효기간",
          dataField: "svc_coupon_limit_name",
          style: "aui-center",
        },
        {
          headerText: "적용모델",
          dataField: "machine_name",
          style: "aui-center",
        },
        {
          headerText: "포함범위",
          dataField: "scope_text",
          style: "aui-left",
        },
        {
          headerText: "출하시지급여부",
          dataField: "out_apply_yn",
          style: "aui-center",
        },
        {
          headerText: "사용여부",
          dataField: "use_yn",
          style: "aui-center",
        },
        {
          headerText: "등록일자",
          dataField: "reg_date",
          dataType: "date",
          formatString: "yyyy-mm-dd",
          style: "aui-center",
        }, {
          headerText: "등록자",
          dataField: "mem_name",
          style: "aui-center",
        },
      ];
      auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
      AUIGrid.setGridData(auiGrid, []);
      AUIGrid.bind(auiGrid, "cellClick", function (event) {
        if (event.dataField == "svc_coupon_name") {
          var param = {
            "svc_coupon_no": event.item.svc_coupon_no,
          };
          var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=600, left=0, top=0";
          $M.goNextPage("/serv/serv0301p01", $M.toGetParam(param), {popupStatus: popupOption});
        }
      });

      $("#auiGrid").resize();
    }

    // 조회
    function goSearch() {
      var param = {
        s_machine_name: $M.getValue("s_machine_name"),
        s_svc_coupon_name: $M.getValue("s_svc_coupon_name"),
        s_use_yn: $M.getValue("s_use_yn")
      };
      $M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: 'get'},
        function (result) {
          if (result.success) {
            $("#total_cnt").html(result.total_cnt);
            AUIGrid.setGridData(auiGrid, result.list);
          }
        }
      );
    }

    function fnDownloadExcel() {
      // 제외항목
      var exportProps = {
        // exceptColumnFields : ["removeBtn"]
      };
      fnExportExcel(auiGrid, "쿠폰관리", exportProps);
    }

    // 신규등록
    function goNew() {
      $M.goNextPage("/serv/serv030101");
    }

    // 엔터키 이벤트
    function enter(fieldObj) {
      var field = ["s_svc_coupon_name", "s_machine_name"];
      $.each(field, function () {
        if (fieldObj.name == this) {
          goSearch();
        }
      });
    }
  </script>
</head>
<body>
<form id="main_form" name="main_form">
  <div class="layout-box">
    <!-- contents 전체 영역 -->
    <div class="content-wrap">
      <div class="content-box">
        <!-- 메인 타이틀 -->
        <div class="main-title">
          <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
        <!-- /메인 타이틀 -->
        <div class="contents">
          <!-- 검색영역 -->
          <div class="search-wrap">
            <table class="table table-fixed">
              <colgroup>
                <col width="65px">
                <col width="120px">
                <col width="45px">
                <col width="120px">
                <col width="70px">
                <col width="100px">
                <col width="">
              </colgroup>
              <tbody>
              <tr>
                <th>적용모델</th>
                <td>
                  <input type="text" class="form-control" id="s_machine_name" name="s_machine_name">
                </td>
                <th>쿠폰명</th>
                <td>
                  <input type="text" class="form-control" id="s_svc_coupon_name" name="s_svc_coupon_name">
                </td>
                <th>사용여부</th>
                <td>
                  <select class="form-control" id="s_use_yn" name="s_use_yn">
                    <option value="">전체</option>
                    <option value="Y">사용</option>
                    <option value="N">미사용</option>
                  </select>
                </td>
                <td>
                  <button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">
                    조회
                  </button>
                </td>
              </tr>
              </tbody>
            </table>
          </div>
          <!-- /검색영역 -->
          <!-- 그리드 타이틀, 컨트롤 영역 -->
          <div class="title-wrap mt10">
            <h4>조회결과</h4>
            <div class="btn-group">
              <div class="right">
                <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
                  <jsp:param name="pos" value="TOP_R"/>
                </jsp:include>
              </div>
            </div>
          </div>
          <!-- /그리드 타이틀, 컨트롤 영역 -->
          <div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
          <div class="btn-group mt5">
            <div class="left">
              총 <strong class="text-primary" id="total_cnt">0</strong>건
            </div>
            <div class="right">
              <button type="button" class="btn btn-info" onclick="javascript:goNew();">쿠폰신규발행</button>
            </div>
          </div>
        </div>
      </div>
      <jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
    </div>
    <!-- /contents 전체 영역 -->
  </div>
</form>
</body>
</html>