<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 고객 App관리 > 자주 하는 질문
-- 작성자 : 한승우
-- 최초 작성일 : 2023-07-19 11:42:27
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
  <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
  <script type="text/javascript">

    var orgCodeArr = [];
    var jobCdArr = [];
    var gradeCdArr = [];

    $(document).ready(function() {
      createLeftAUIGrid();
      createRightAUIGrid();
      goSearch();
    });

    // 엔터키 이벤트
    function enter(fieldObj) {
      var field = ["s_title", "s_reg_mem_name"];
      $.each(field, function() {
        if(fieldObj.name == this) {
          goSearch('');
        };
      });
    }

    //카테고리 조회
    function goCategorySearch() {
      var param = {
        "s_group_code" : "C_FAQ_TYPE",
        "s_use_yn" : "Y",
      };
      $M.goNextPageAjax(this_page + "/category/search", $M.toGetParam(param), {method : 'get'},
        function(result) {
          if(result.success) {
            AUIGrid.setGridData(auiLeftGrid, result.list);
            AUIGrid.expandAll(auiLeftGrid);
          }
        }
      );
    }

    // 메뉴 트리 그리드
    function createLeftAUIGrid() {
      var gridPros = {
        rowIdField : "code",
        displayTreeOpen :true,
        rowCheckDependingTree : true,
        showRowNumColumn: true,
        enableFilter :true,
      };
      var columnLayout = [
        {
          headerText : "카테고리명",
          dataField : "code_name",
          style : "aui-left",
          editable : false,
        },
        {
          headerText : "사용여부",
          dataField : "use_yn",
          style : "aui-center",
          editable : false,
          width : "80",
          minWidth : "50",
        },
        {
          headerText : "노출순서",
          dataField : "sort_no",
          style : "aui-center",
          editable : false,
          width : "80",
          minWidth : "50",
        },
        {
          dataField : "code",
          visible : false,
        }
      ];

      auiLeftGrid = AUIGrid.create("#auiLeftGrid", columnLayout, gridPros);
      AUIGrid.setGridData(auiLeftGrid, ${list});
      $("#auiLeftGrid").resize();
      AUIGrid.bind(auiLeftGrid, "cellClick", function(event){
        var CategoryCode = event.item["code"];
        goSearch(CategoryCode);
      });
    }

    //그리드셀 클릭시
    function goSearch(CategoryCode) {
      if(CategoryCode == null || CategoryCode == undefined) {
        CategoryCode = "";
      }

      var params = {
        "s_c_cs_faq_cd" : CategoryCode,
        "s_title" : $M.getValue("s_title"),
        "s_reg_mem_name" : $M.getValue("s_reg_mem_name"),
        "s_sort_key" : "SORT_NO",
        "s_sort_method" : "asc"
      };
      $M.goNextPageAjax(this_page + "/search", $M.toGetParam(params), { method : 'get'},
        function(result) {
          if(result.success) {
            AUIGrid.setGridData(auiRightGrid, result.mainList);
            AUIGrid.setGridData(auiLeftGrid, result.list);
            AUIGrid.expandAll(auiRightGrid);
            $("#total_cnt").html(result.total_cnt);
          }
        }
      );
    }

    // 공지사항 리스트
    function createRightAUIGrid() {
      var gridPros = {
        rowIdField : "c_faq_seq",
        rowCheckDependingTree : true,
        showRowNumColumn: true,
        enableFilter :true,

      };
      var columnLayout = [
        {
          dataField : "c_faq_seq",
          visible : false,
        },
        {
          headerText : "제목",
          dataField : "title",
          width : "380",
          minWidth : "50",
          style : "aui-left aui-popup",
          editable : false,
          renderer : {
            type : "TemplateRenderer"
          },
        },
        {
          headerText : "등록일",
          dataField : "reg_date",
          dataType : "date",
          formatString : "yy-mm-dd",
          width : "90",
          minWidth : "50",
          style : "aui-center",
          editable : false,
        },
        {
          headerText : "작성자",
          dataField : "reg_mem_name",
          width : "100",
          minWidth : "50",
          style : "aui-center",
          editable : false,
        },
        {
          headerText : "사용여부",
          dataField : "use_yn",
          width : "80",
          minWidth : "50",
          style : "aui-center",
        },
        {
          headerText : "노출순서",
          dataField : "sort_no",
          width : "80",
          minWidth : "50",
          style : "aui-center",
        },
        {
          headerText : "조회수",
          dataField : "read_cnt",
          width : "80",
          minWidth : "50",
          style : "aui-center",
        },
      ];
      auiRightGrid = AUIGrid.create("#auiRightGrid", columnLayout, gridPros);
      AUIGrid.setGridData(auiRightGrid, []);
      $("#auiRightGrid").resize();
      AUIGrid.bind(auiRightGrid, "cellClick", function(event){
        if(event.dataField == "title") {
          var param = {
            "c_faq_seq" : event.item["c_faq_seq"]
          };
          var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=850, height=800, left=0, top=0";
          $M.goNextPage('/cust/cust0508p01', $M.toGetParam(param), {popupStatus : poppupOption});
        }
      });
    }

    // 고객앱 FAQ 카테고리 코드관리 팝업 호출
    function goCFaqCdMngPopup() {
      var param = {
        group_code : "C_FAQ_TYPE",
        all_yn: "Y",
      };
      var popupOption = "";
      openGroupCodeDetailPanel($M.toGetParam(param));
    }

    // 자주하는질문 등록 페이지 이동
    function goNewCFaq() {
      $M.goNextPage("/cust/cust050801");
    }

    // 엑셀 다운로드
    function fnDownloadExcel() {
      var exportProps = {
        // 제외항목
      };
      fnExportExcel(auiRightGrid, "자주하는질문", exportProps);
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
            <table class="table">
              <colgroup>
                <col width="45px">
                <col width="120px">
                <col width="55px">
                <col width="120px">
                <col width="">
              </colgroup>
              <tbody>
              <tr>
                <th>제목</th>
                <td>
                  <input type="text" class="form-control" id="s_title" name="s_title">
                </td>
                <th>작성자</th>
                <td>
                  <input type="text" class="form-control" id="s_reg_mem_name" name="s_reg_mem_name">
                </td>
                <td>
                  <button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch('');">조회</button>
                </td>
              </tr>
              </tbody>
            </table>
          </div>
          <!-- /검색영역 -->
          <div class="row">
            <div class="col-3">
              <!-- 카테고리 -->
              <div class="title-wrap mt10">
                <h4>카테고리</h4>
                <div class="btn-group">
                  <div class="right">
<%--                    <button type="button" onclick=AUIGrid.expandAll(auiLeftGrid); class="btn btn-default"><i class="material-iconsadd text-default"></i>펼침</button>--%>
<%--                    <button type="button" onclick=AUIGrid.collapseAll(auiLeftGrid); class="btn btn-default"><i class="material-iconsremove text-default"></i>접힘</button>--%>
                    <button type="button" onclick="javascript:goCFaqCdMngPopup();" class="btn btn-default"><i class="text-default"></i>카테고리 코드관리</button>
                  </div>
                </div>
              </div>
              <div id="auiLeftGrid" style="margin-top: 5px;height: 550px;"></div>
              <!-- /카테고리 -->
            </div>
            <div class="col-9">
              <!-- 조회결과 -->
              <div class="title-wrap mt10">
                <h4>조회결과</h4>
                <div class="btn-group">
                  <div class="right">
                    <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
                  </div>
                </div>
              </div>
              <div id="auiRightGrid" style="margin-top: 5px; height:550px;"></div>
              <div class="btn-group mt5">
                <div class="left">
                  총 <strong class="text-primary" id="total_cnt">0</strong>건
                </div>
                <div class="right">
                  <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
                </div>
              </div>
              <!-- /조회결과 -->
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
