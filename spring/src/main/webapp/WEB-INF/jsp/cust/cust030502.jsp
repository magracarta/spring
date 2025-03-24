<%@ page contentType="text/html;charset=utf-8" language="java" %><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 거래현황 > 쿠폰사용내역 > 서비스쿠폰 > null
-- 작성자 : 정재호
-- 최초 작성일 : 2024-01-24 00:00:00
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
  <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
  <script type="text/javascript">

    $(document).ready(function () {
      createAUIGrid();
      goSearch();
    });

    function createAUIGrid() {
      var gridPros = {
        rowIdField: "_$uid",
        enableCellMerge: true,
        cellMergeRowSpan: true,
      };
      var columnLayout = [
        {
          dataField : "aui_status_cd",
          visible: false
        },
        {
          headerText: "고객 서비스 쿠폰 번호",
          dataField: "cust_svc_coupon_no",
          visible: false,
        },
        {
          headerText: "발행일자",
          dataField: "issue_dt",
          style: "aui-center aui-popup",
          dataType: "date",
          formatString: "yyyy-mm-dd",
          width : "100",
          // 그리드 스타일 함수 정의
          // styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
          //   if(item.auto_yn == 'N') {
          //     return "aui-popup";
          //   };
          //   return "aui-center";
          // }
        },
        {
          headerText: "고객명",
          dataField: "cust_name",
          style: "aui-center",
          width : "100",
        },
        {
          headerText: "연락처",
          dataField: "hp_no",
          style: "aui-center",
          width : "100",
        },
        {
          headerText: "구분",
          dataField: "gubun_name",
          style: "aui-center",
          width : "100",
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
          headerText: "차대번호",
          dataField: "body_no",
          style: "aui-center",
          width : "180",
        },
        {
          headerText: "유효기간",
          dataField: "expiration_period_dt",
          dataType: "date",
          formatString: "yyyy-mm-dd",
          style: "aui-center",
          width : "180",
        },
        {
          headerText: "소멸예정일",
          dataField: "expire_plan_dt",
          dataType: "date",
          formatString: "yyyy-mm-dd",
          style: "aui-center",
          width : "100",
        },
        {
          headerText: "처리일자",
          dataField: "apply_dt",
          dataType: "date",
          formatString: "yyyy-mm-dd",
          style: "aui-center",
          width : "100",
        },
        {
          headerText: "비고",
          dataField: "remark",
          style: "aui-center",
          width : "100",
        },
      ];

      auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
      AUIGrid.setGridData(auiGrid, []);
      $("#auiGrid").resize();

      AUIGrid.bind(auiGrid, "cellClick", function (event) {
        // 발행일자 클릭 && 임의발행인 경우만 상세 팝업 호출 
        if (event.dataField == "issue_dt") {
          // 무상쿠폰 팝업 열기 (상세랑 발급이랑 같이 사용)
          goDetail(event.item.cust_svc_coupon_no);
        }
      });
    }

    // 엔터키 이벤트
    function enter(fieldObj) {
      var field = ["s_date_type", "s_cust_name", "s_coupon_name", "s_auto_yn"];
      $.each(field, function () {
        if (fieldObj.name == this) {
          goSearch();
        }
      });
    }

    // 검색
    function goSearch() {
      if ($M.checkRangeByFieldName("s_gubun_start_dt", "s_gubun_end_dt", true) == false) {
        return;
      }

      var param = {
        "s_date_type": $M.getValue("s_date_type"),
        "s_gubun_start_dt": $M.getValue("s_gubun_start_dt"),
        "s_gubun_end_dt": $M.getValue("s_gubun_end_dt"),
        "s_cust_name": $M.getValue("s_cust_name"),
        "s_coupon_name": $M.getValue("s_coupon_name"),
        "s_auto_yn": $M.getValue("s_auto_yn"),
        "s_masking_yn": $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N"
      };
      _fnAddSearchDt(param, 's_gubun_start_dt', 's_gubun_end_dt');
      $M.goNextPageAjax(this_page + '/search', $M.toGetParam(param), {method: 'get'}, function (result) {
        if (result.success) {
          AUIGrid.setGridData(auiGrid, result.list);
          $("#total_cnt").html(result.total_cnt);
        }
      })
    }

    // 엑셀 다운로드
    function fnDownloadExcel() {
      fnExportExcel(auiGrid, "서비스쿠폰 목록");
    }

    // 무상쿠폰 임의발행
    function goNew() {
      var param = {};
      
      var popupOption = "";
      $M.goNextPage('/cust/cust030502p01', $M.toGetParam(param), {popupStatus: popupOption});
    }
    
    function goDetail(custSvcCouponNo) {
      var param = {
        cust_svc_coupon_no : custSvcCouponNo,
      };

      var popupOption = "";
      $M.goNextPage('/cust/cust030502p02', $M.toGetParam(param), {popupStatus: popupOption});
    }

  </script>
</head>
<body style="background : #fff">
<form id="main_form" name="main_form">
  <div class="layout-box">
    <!-- contents 전체 영역 -->
    <div class="content-wrap">
      <div class="content-box">
        <div class="contents" style="margin-top: 10px">
          <div class="search-wrap">
            <table class="table">
              <colgroup>
                <col width="90px">
                <col width="270px">
                <col width="50px">
                <col width="120px">
                <col width="50px">
                <col width="120px">
                <col width="40px">
                <col width="140px">
                <col width="">
              </colgroup>
              <tbody>
              <tr>
                <td>
                  <select class="form-control" id="s_date_type" name="s_date_type">
                    <option value="issue_dt">발행일자</option>
                    <option value="apply_dt">처리일자</option>
                    <option value="expire_plan_dt">소멸예정일</option>
                  </select>
                </td>
                <td>
                  <div class="form-row inline-pd">
                    <div class="col-5">
                      <div class="input-group dev_nf">
                        <input type="text" class="form-control border-right-0 calDate" id="s_gubun_start_dt"
                               name="s_gubun_start_dt" value="${searchDtMap.s_start_dt}" dateformat="yyyy-MM-dd"
                               alt="조회 시작일">
                      </div>
                    </div>
                    <div class="col-auto">~</div>
                    <div class="col-5">
                      <div class="input-group dev_nf">
                        <input type="text" class="form-control border-right-0 calDate" id="s_gubun_end_dt"
                               name="s_gubun_end_dt" dateformat="yyyy-MM-dd" alt="조회 완료일"
                               value="${searchDtMap.s_end_dt}">
                      </div>
                    </div>
                    <jsp:include page="/WEB-INF/jsp/common/searchDtType.jsp">
                      <jsp:param name="st_field_name" value="s_gubun_start_dt"/>
                      <jsp:param name="ed_field_name" value="s_gubun_end_dt"/>
                      <jsp:param name="click_exec_yn" value="Y"/>
                      <jsp:param name="exec_func_name" value="goSearch();"/>
                    </jsp:include>
                  </div>
                </td>
                <th>고객명</th>
                <td>
                  <input type="text" class="form-control" id="s_cust_name" name="s_cust_name">
                </td>
                <th>쿠폰명</th>
                <td>
                  <input type="text" class="form-control" id="s_coupon_name" name="s_coupon_name">
                </td>
                <th>구분</th>
                <td>
                  <select class="form-control" id="s_coupon_issue_cd" name="s_auto_yn">
                    <option value="">- 전체 -</option>
                    <option value="Y">무상</option>
                    <option value="N">임의발행</option>
                  </select>
                </td>
                <td>
                  <button type="button" class="btn btn-important" style="width: 50px;" onclick="javasctipt:goSearch();">
                    조회
                  </button>
                </td>
              </tr>
              </tbody>
            </table>
          </div>
          <div class="title-wrap mt10">
            <h4>조회결과</h4>
            <div class="btn-group">
              <div class="right">
                <c:if test="${page.add.POS_UNMASKING eq 'Y'}">
                  <div class="form-check form-check-inline">
                    <input class="form-check-input" type="checkbox" id="s_masking_yn" name="s_masking_yn" <c:if
                      test="${page.masking_default_yn eq 'Y'}"> checked</c:if> value="Y" >
                    <label class="form-check-input" for="s_masking_yn">마스킹 적용</label>
                  </div>
                </c:if>
                <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
                  <jsp:param name="pos" value="MID_L"/>
                </jsp:include>
              </div>
            </div>
          </div>
          <div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
          <div class="btn-group mt5">
            <div class="left">
              총 <strong class="text-primary" id="total_cnt">${total_cnt}</strong>건
            </div>
            <div class="right">
              <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
                <jsp:param name="pos" value="BOM_R"/>
              </jsp:include>
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