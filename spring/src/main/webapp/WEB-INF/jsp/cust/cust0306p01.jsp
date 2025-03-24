<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 거래현황 > 마일리지관리 > 전표관리 > 등록
-- 작성자 : 한승우
-- 최초 작성일 : 2023-08-11 15:50:00
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
  <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
  <script type="text/javascript">
    $(document).ready(function () {
      fnInit();
    });

    //고객정보가 있으면 바로 세팅하기
    function fnInit() {

      if ("${cust_no}" != ""){
        var custNo = "${cust_no}";
        getCustInfo(custNo);

      }

      // 마일리지 소멸일자 Default: 적립일로부터 2년 후
      var now = "${inputParam.s_current_dt}";
      $M.setValue("expire_plan_dt", $M.addYears($M.toDate(now),2));

    }

    function getCustInfo(custNo) {

      var param = {
        s_cust_no : custNo
      };
      $M.goNextPageAjax("/comp/comp0301/search", $M.toGetParam(param), {method : 'get'},
              function(result) {
                if(result.success) {
                  var list = result.list;
                  switch(list.length) {
                    case 0 :
                      break;
                    case 1 :
                      var row = list[0];
                      fnSetCustInfo(row);
                      break;
                    default :
                      break;
                  }
                }
              }
      );
    }

    function fnSetBregInfo(data) {

      var param = {
        breg_seq : data.breg_seq,
        breg_name : data.breg_name,
        breg_no : data.breg_no,
        breg_rep_name : data.breg_rep_name,
        breg_cor_type : data.breg_cor_type,
        breg_cor_part : data.breg_cor_part,
        biz_post_no : data.biz_post_no,
        biz_addr1 : data.biz_addr1,
        biz_addr2 : data.biz_addr2

      }
      console.log(" ---> ", param);
      $M.setValue(param);
    }

    function fnSetCustInfo(data) {
      console.log("data : ", data);
      //고객조회 - 사업자인경우 사업자 주소도 가져오기

      if ( data.breg_no == ""){
        alert("사업자 정보가 없습니다.");
      }

      var param = {
        cust_no : data.cust_no,
        cust_name : data.real_cust_name,
        deposit_name : data.deposit_name,
        cust_hp_no : $M.phoneFormat(data.real_hp_no),
        sum_balance_amt : data.sum_balance_amt,
        breg_seq : data.breg_seq,
        breg_name : data.breg_name,
        breg_no : data.breg_no,
        sale_mem_name : data.sale_mem_name,
        breg_rep_name : data.breg_rep_name,
        breg_cor_type : data.breg_cor_type,
        breg_cor_part : data.breg_cor_part,
        biz_post_no : data.biz_post_no,
        biz_addr1 : data.biz_addr1,
        biz_addr2 : data.biz_addr2,
        total_mile_amt : data.total_mile_amt
      }
      console.log(" ---> ", param);
      $M.setValue(param);
    }

    // 문자발송
    function fnSendSms() {
      var param = {
        name : $M.getValue("cust_name"),
        hp_no : $M.getValue("cust_hp_no")
      }
      openSendSmsPanel($M.toGetParam(param));
    }

    function fnSetMileIssueName() {
      $M.setValue("mile_issue_name", $("#mile_issue_cd > option:checked")[0].innerText);
    }

    // 저장
    function goSave() {

      var frm = document.main_form;

      if ($M.validation(frm) == false) {
        return;
      };

      if ($M.getValue("mile_amt") <= 0 ){
        alert("마일리지금액은 0보다 큰 값만 지정 가능합니다.");
        return;
      }

      if ($M.getValue("expire_plan_dt") <= "${inputParam.s_current_dt}" ){
        alert("소멸예정일은 오늘이후날짜만 지정 가능합니다.");
        return;
      }

      if ($M.getValue("expire_plan_dt") <= $M.getValue("inout_dt") ){
        alert("소멸예정일은 전표날짜 이후로만 지정 가능합니다.");
        return;
      }

      $M.goNextPageAjaxSave(this_page + "/save", $M.toValueForm(frm), { method : "POST"},
              function(result) {
                if(result.success) {
                  alert(result.result_msg);
                  // 창닫기
                  window.close();
                  window.opener.goSearch();
                };
              }
      );
    }

    function fnClose() {
      window.close();
    }

  </script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
  <!-- 팝업 -->
  <div class="popup-wrap width-100per">
    <!-- 타이틀영역 -->
    <div class="main-title">
      <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
    </div>
    <!-- /타이틀영역 -->
    <!-- contents 전체 영역 -->
    <div class="content-wrap" >
      <!-- 폼테이블 -->
      <div>
        <table class="table-border">
          <colgroup>
            <col width="100px">
            <col width="">
            <col width="100px">
            <col width="">
          </colgroup>
          <tbody>
          <tr>
            <th class="text-right">전표번호</th>
            <td>
              <input type="text" class="form-control width120px" id="inout_doc_no" name="inout_doc_no" value=""  readonly="readonly">
            </td>
            <th class="text-right essential-item">전표일자</th>
            <td>
              <div class="input-group width120px">
                <input type="text" class="form-control border-right-0 calDate rb" id="inout_dt" name="inout_dt"   required="required" dateformat="yyyy-MM-dd" alt="전표일자" value="${inputParam.s_current_dt}">
              </div>
            </td>
          </tr>
          <tr>
            <th class="text-right essential-item">고객명</th>
            <td>
              <div class="input-group">
                <input type="text" class="form-control border-right-0 width100px" id="cust_name" name="cust_name" required="required" alt="고객명" value=""   readonly="readonly">
                <input type="hidden" id="cust_no" 	name="cust_no" 	value=""  >
                <button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openSearchCustPanel('fnSetCustInfo');"><i class="material-iconssearch"></i></button>
              </div>
            </td>
            <th class="text-right essential-item">연락처</th>
            <td>
              <div class="input-group">
                <input type="text" class="form-control border-right-0 width100px" id="cust_hp_no" name="cust_hp_no"  required="required" alt="연락처" value=""   readonly="readonly" >
                <button type="button" class="btn btn-icon btn-primary-gra"  onclick="javascript:fnSendSms();"><i class="material-iconsforum"></i></button>
              </div>
            </td>
          </tr>
          <tr>
            <th class="text-right">업체명</th>
            <td>
              <input type="text" class="form-control width120px" id="breg_name" name="breg_name" value="" readonly="readonly">
            </td>
            <th class="text-right">대표자</th>
            <td>
              <input type="text" class="form-control width120px" id="breg_rep_name" name="breg_rep_name" value="" readonly="readonly">
            </td>
          </tr>
          <tr>
            <th class="text-right">사업자No</th>
            <td>
              <div class="form-row inline-pd widthfix">
                <div class="col width160px">
                  <input type="text" class="form-control" id="breg_no" 	name="breg_no" value=""   readonly="readonly">
                </div>
                <div class="col width60px">
                  <button type="button" class="btn btn-primary-gra" onclick="javasctipt:openSearchBregInfoPanel('fnSetBregInfo');">변경</button>
                </div>
              </div>
            </td>
            <th class="text-right">누적마일리지</th>
            <td>
              <div class="form-row inline-pd widthfix">
                <div class="col width120px">
                  <input type="text" class="form-control" id="total_mile_amt" name="total_mile_amt" value="" format="decimal" readonly="readonly">
                </div>
                <div class="col width16px">원</div>
              </div>
            </td>
          </tr>
          <tr>
            <th class="text-right">주소</th>
            <td colspan="3">
              <div class="form-row inline-pd mb7 widthfix">
                <div class="col-3">
                  <input type="text" class="form-control" id="biz_post_no" name="biz_post_no" value=""  readonly="readonly">
                </div>
                <div class="col-9">
                  <input type="text" class="form-control" id="biz_addr1" name="biz_addr1" value=""  readonly="readonly">
                </div>
              </div>
              <div class="form-row inline-pd">
                <div class="col-12">
                  <input type="text" class="form-control" id="biz_addr2" name="biz_addr2" value=""  readonly="readonly" >
                </div>
              </div>
            </td>
          </tr>
          <tr>
            <th class="text-right essential-item">적립 발행구분</th>
            <td  colspan="3">
              <input type="hidden" id="mile_issue_name" name="mile_issue_name" value="임의발행"/>
              <select class="form-control width120px essential-bg" id="mile_issue_cd" name="mile_issue_cd" required="required" alt="발행구분" onchange="javascript:fnSetMileIssueName();">
                <c:forEach var="item" items="${codeMap['MILE_ISSUE']}">
                  <c:if test="${item.code_name ne '부품' && item.code_name ne '정비' && item.code_name ne '렌탈'}">
                    <option value="${item.code_value}">${item.code_name}</option>
                  </c:if>
                </c:forEach>
              </select>
            </td>
          </tr>
          <tr>
            <th class="text-right essential-item">마일리지금액</th>
            <td>
              <div class="form-row inline-pd widthfix">
                <div class="col width120px">
                  <input type="text" class="form-control text-right" id="mile_amt" name="mile_amt"  value=""  required="required" alt="마일리지금액" datatype="int" format="decimal"  min="10" >
                </div>
                <div class="col width16px">원</div>
              </div>
            </td>
            <th class="text-right essential-item">소멸예정일</th>
            <td>
              <div class="input-group width120px">
                <input type="text" class="form-control border-right-0 calDate rb" id="expire_plan_dt" name="expire_plan_dt" dateformat="yyyy-MM-dd"  required="required" alt="소멸예정일" value="">
              </div>
            </td>
          </tr>
          <tr>
            <th class="text-right essential-item">처리자</th>
            <td>
              <input type="text" class="form-control width120px" id="kor_name" name="kor_name"  value="${SecureUser.kor_name}"   readonly="readonly">
              <input type="hidden" id="mem_no" name="mem_no" value="${SecureUser.mem_no}"  >
              <input type="hidden" id="org_code" name="org_code" value="${SecureUser.org_code}">
            </td>
            <th class="text-right essential-item">처리일자</th>
            <td>
              <input type="text" class="form-control width120px" id="issue_dt" name="issue_dt"  value="${inputParam.s_current_dt}" dateformat="yyyy-MM-dd" readonly="readonly">
            </td>
          </tr>
          <tr>
            <th class="text-right">비고</th>
            <td colspan="3">
              <textarea class="form-control" id="remark" name="remark" value=""  style="height: 50px;"></textarea>
            </td>
          </tr>
          </tbody>
        </table>
      </div>
      <!-- /폼테이블 -->
      <!-- 그리드 서머리, 컨트롤 영역 -->
      <div class="btn-group mt5">
        <div class="right">
          <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
        </div>
      </div>
      <!-- /그리드 서머리, 컨트롤 영역 -->
    </div>
    <!-- /contents 전체 영역 -->
  </div>
  <!-- /팝업 -->
</form>
</body>
</html>
