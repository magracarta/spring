<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 거래현황 > 마일리지관리 > 전체관리 > null
-- 작성자 : 한승우
-- 최초 작성일 : 2023-08-11 15:06:00
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
  <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
  <script type="text/javascript">

    $(document).ready(function() {
      // AUIGrid 생성
      createAUIGridLeft();
      createAUIGridRight();
    });

    // 엔터키 이벤트
    function enter(fieldObj) {
      var field = ["s_cust_name","s_hp_no"];
      $.each(field, function() {
        if(fieldObj.name == this) {
          goSearch();
        };
      });
    }

    //조회
    function goSearch() {
      if($M.checkRangeByFieldName("s_gubun_start_dt", "s_gubun_end_dt", true) == false) {
        return;
      };

      var param = {
        "s_sort_key" : "reg_date",
        "s_sort_method" : "desc",
        "s_cust_name" : $M.getValue("s_cust_name"),
        "s_hp_no" : $M.getValue("s_hp_no"),
        "s_balance_amt_non_zero" : $M.getValue("s_balance_amt_non_zero"),
        "s_masking_yn" : $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N"
      };
      $M.goNextPageAjax(this_page + '/search', $M.toGetParam(param), {method : 'get'},
              function(result) {
                if(result.success) {
                  AUIGrid.setGridData(auiGridLeft, result.custList);

                  // 요청예정목록 초기화
                  AUIGrid.setGridData(auiGridRight, []);
                  $M.setValue("cust_name","");
                  $M.setValue("cust_no","");
                  $M.setValue("hp_no","");
                  $M.setValue("sum_balance_amt","");

                  $("#total_cust_cnt").html(result.total_cust_cnt);
                };
              }
      );
    }

    //그리드생성
    function createAUIGridLeft() {
      var gridPros = {
        rowIdField : "$uid",
        showStateColumn : false,
        showRowNumColumn: true,
        showBranchOnGrouping : false,
        showFooter : true,
        footerPosition : "top",
        editable : false,
        enableMovingColumn : false
      };
      var columnLayout = [
        {
          dataField : "cust_no",
          visible : false
        },
        {
          headerText : "고객명",
          dataField : "cust_name",
          width : "95",
          minWidth : "90",
          style : "aui-center aui-popup",
        },
        {
          headerText : "연락처",
          dataField : "hp_no",
          width : "180",
          minWidth : "110",
          style : "aui-center"
        },
        {
          headerText : "적립총액",
          dataField : "total_amt",
          dataType : "numeric",
          formatString : "#,##0",
          width : "120",
          minWidth : "80",
          style : "aui-right",
        },
        {
          headerText : "누적잔액",
          dataField : "balance_amt",
          dataType : "numeric",
          formatString : "#,##0",
          width : "120",
          minWidth : "80",
          style : "aui-right",
        }
      ];

      // 푸터레이아웃
      var footerColumnLayout = [
        {
          labelText : "합계",
          positionField : "cust_name",
          style : "aui-center aui-footer",
          colSpan : 2
        },
        {
          dataField : "total_amt",
          positionField : "total_amt",
          operation : "SUM",
          formatString : "#,##0",
          style : "aui-right aui-footer",
        },
        {
          dataField : "balance_amt",
          positionField : "balance_amt",
          operation : "SUM",
          formatString : "#,##0",
          style : "aui-right aui-footer",
        }
      ];

      auiGridLeft = AUIGrid.create("#auiGridLeft", columnLayout, gridPros);
      // 푸터 객체 세팅
      AUIGrid.setFooter(auiGridLeft, footerColumnLayout);
      AUIGrid.setGridData(auiGridLeft, []);
      AUIGrid.bind(auiGridLeft, "cellClick", function(event) {
        if(event.dataField == "cust_name") {
          var custNo = event.item["cust_no"];
          goCustMileInfo(custNo);
        }
      });
      $("#auiGridLeft").resize();
    }

    // 처리내역 조회
    function goCustMileInfo(custNo) {
      var param = {
        "s_cust_no" : custNo,
        "s_sort_key" : "reg_date",
        "s_sort_method" : "desc",
      };
      $M.setValue("cust_no",custNo);

      $M.goNextPageAjax(this_page + "/searchDetail", $M.toGetParam(param), {method : 'get'},
              function(result) {
                if(result.success) {
                  // 데이터 그리드 세팅
                  AUIGrid.setGridData(auiGridRight, result.mileInfoList);
                  $("#total_proc_cnt").html(result.total_proc_cnt);

                  $M.setValue("cust_name" , result.cust_name);
                  $M.setValue("hp_no" , result.hp_no);
                  $M.setValue("sum_balance_amt" , result.sum_balance_amt);
                };
              }
      );
    }

    //그리드생성
    function createAUIGridRight() {
      var gridPros = {
        rowIdField : "inout_doc_no",
        showStateColumn : false,
        showRowNumColumn: true,
        showBranchOnGrouping : false,
        editable : false,
        enableMovingColumn : false
      };
      var columnLayout = [
        {
          headerText : "처리일자",
          dataField : "proc_dt",
          dataType : "date",
          formatString : "yy-mm-dd",
          width : "100",
          minWidth : "70",
          style : "aui-center"
        },
        {
          dataField : "cust_mile_no",
          visible : false
        },
        {
          dataField : "cust_no",
          visible : false
        },
        {
          dataField : "input_type_cd",
          visible : false
        },
        {
          dataField : "inout_doc_type_cd",
          visible : false
        },
        {
          headerText : "전표번호",
          dataField : "inout_doc_no",
          width : "150",
          minWidth : "70",
          style : "aui-center aui-popup",
        },
        {
          headerText : "구분",
          dataField : "mile_gubun",
          width : "70",
          minWidth : "70",
          style : "aui-center",
        },
        {
          headerText : "금액",
          dataField : "mile_amt",
          dataType : "numeric",
          formatString : "#,##0",
          width : "120",
          minWidth : "80",
          style : "aui-right",
        },
        {
          headerText : "누적잔액",
          dataField : "balance_amt",
          dataType : "numeric",
          formatString : "#,##0",
          width : "120",
          minWidth : "80",
          style : "aui-right",
        },
        {
          headerText : "소멸예정",
          dataField : "expire_plan_dt",
          dataType : "date",
          formatString : "yy-mm-dd",
          width : "100",
          minWidth : "70",
          style : "aui-center",
        }
      ];


      auiGridRight = AUIGrid.create("#auiGridRight", columnLayout, gridPros);
      AUIGrid.setGridData(auiGridRight, []);
      $("#auiGridRight").resize();
      AUIGrid.bind(auiGridRight, "cellClick", function(event) {
        if(event.item.cust_no == "" && event.item.cust_mile_no == "" ){
          alert("고객 마일리지를 선택해주세요");
          return;
        } else if(event.dataField == "inout_doc_no") {
          // 적립, 소멸은 마일리지전표상세 팝업 Open
          // 사용은 매출처리상세 팝업 Open
          var inoutDocNo = event.item["inout_doc_no"];
          var param = {
            inout_doc_no : inoutDocNo
          }
          if (event.item["mile_gubun"] == "사용"){
            var popupOption = "scrollbars=yes, resizable=1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1300, height=780, left=0, top=0";
            $M.goNextPage("/cust/cust0202p01", $M.toGetParam(param), {popupStatus : popupOption});
          } else {
            $M.goNextPage("/cust/cust0306p02", $M.toGetParam(param), {popupStatus : ""});
          }
        }
      });
    }

    function fnDownloadExcel() {
      // 엑셀 내보내기 속성
      var exportProps = {
      };
      fnExportExcel(auiGridLeft, "마일리지전체관리", exportProps);
    }
  </script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
  <div class="layout-box">
    <!-- contents 전체 영역 -->
    <div class="content-wrap">
      <div class="content-box">
        <div class="contents">

          <input type="hidden" id="cust_no" name="cust_no" >

          <div class="row">
            <div class="col-5">
              <!-- 검색영역 -->
              <div class="search-wrap mt10">
                <table class="table">
                  <colgroup>
                    <col width="50px">
                    <col width="120px">
                    <col width="50px">
                    <col width="120px">
                    <col width="150px">
                    <col width="">
                  </colgroup>
                  <tbody>
                  <tr>
                    <th>고객명</th>
                    <td>
                      <input type="text" class="form-control" id="s_cust_name" name="s_cust_name">
                    </td>
                    <th>연락처</th>
                    <td>
                      <input type="text" class="form-control" id="s_hp_no" name="s_hp_no">
                    </td>
                    <td class="pl10">
                      <div class="form-check form-check-inline">
                        <input class="form-check-input" type="checkbox"  id="s_balance_amt_non_zero" name="s_balance_amt_non_zero"   value="Y"  checked="checked" >
                        <label class="form-check-label" for="s_balance_amt_non_zero"  >잔액 있는 고객만</label>
                      </div>
                    </td>
                    <td>
                      <button type="button" class="btn btn-important" style="width: 50px;" onclick="javasctipt:goSearch();">조회</button>
                    </td>
                  </tr>
                  </tbody>
                </table>
              </div>
              <!-- /검색영역 -->
              <!-- 조회결과 -->
              <div class="title-wrap mt10">
                <h4>조회결과</h4>
                <div class="right">
                  <c:if test="${page.add.POS_UNMASKING eq 'Y'}">
                    <div class="form-check form-check-inline">
                      <input  class="form-check-input"  type="checkbox" id="s_masking_yn" name="s_masking_yn"<c:if test="${page.masking_default_yn eq 'Y'}" > checked</c:if> value="Y" >
                      <label  class="form-check-input"  for="s_masking_yn" >마스킹 적용</label>
                    </div>
                  </c:if>
                  <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_L"/></jsp:include>
                </div>
              </div>
              <div id="auiGridLeft" style="margin-top: 5px; height: 555px;"></div>
              <!-- /조회결과 -->
            </div>
            <div class="col-7 mt10">
              <!-- 폼테이블 -->
              <table class="table-border">
                <colgroup>
                  <col width="100px">
                  <col width="">
                  <col width="100px">
                  <col width="">
                  <col width="100px">
                  <col width="">
                </colgroup>
                <tbody>
                <tr>
                  <th class="text-right">고객명</th>
                  <td>
                    <input type="text" class="form-control width120px" id="cust_name" name="cust_name" readonly="readonly" >
                  </td>
                  <th class="text-right">연락처</th>
                  <td>
                    <input type="text" class="form-control width120px" id="hp_no" name="hp_no"  readonly="readonly"    >
                  </td>
                  <th class="text-right">총 누적마일리지</th>
                  <td>
                    <input type="text" class="form-control width120px" id="sum_balance_amt" name="sum_balance_amt"  readonly="readonly"    >
                  </td>
                </tr>
                </tbody>
              </table>
              <!-- /폼테이블 -->
              <!-- 처리내역 -->
              <div class="title-wrap mt10">
                <h4>처리내역</h4>
                <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
              </div>
              <div id="auiGridRight" style="margin-top: 5px; height: 520px;"></div>
              <!-- /처리내역 -->
              <div class="left">
                총 <strong class="text-primary" id="total_proc_cnt">${total_proc_cnt}</strong>건
              </div>
            </div>
          </div>
          <div class="btn-group mt5">
            <div class="left">
              총 <strong class="text-primary" id="total_cust_cnt">${total_cust_cnt}</strong>건
            </div>
            <div class="right">
              <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
            </div>
          </div>
        </div>
      </div>
    </div>
    <!-- /contents 전체 영역 -->
  </div>
</form>
</body>
</html>
