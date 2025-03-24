<%@ page contentType="text/html;charset=utf-8" language="java" %><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 거래현황 > 쿠폰사용내역 > 서비스쿠폰 > 서비스쿠폰상세
-- 작성자 : 정재호
-- 최초 작성일 : 2024-02-06 00:00:00
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
  <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
</head>
<script type="text/javascript">
  var couponList = ${couponList};
  var bodyNoList = ${bodyNoList};

  $(document).ready(function () {
    // 버튼 노출 처리
    $('.cust-tr').show();

    // 수정 불가 처리
    $M.disabled(['cust_name']);
    
    // 셀렉 박스 셋팅
    couponSelectBoxSetting();
    $M.setValue('svc_coupon_no','${info.svc_coupon_no}');
    $M.setValue('body_no', '${info.body_no}');
    $M.setValue('machine_seq', '${info.machine_seq}');
  });

  // 수정 버튼
  function goModify() {
    // 쿠폰 사용 여부
    if('${info.apply_yn}' === 'Y') {
      alert('사용한 쿠폰은 수정 할 수 없습니다.');
      return;
    }
    
    if ($M.validation(document.main_form) == false) {
      return false;
    }

    $M.goNextPageAjaxModify(this_page + '/modify', $M.toValueForm(document.main_form), {method: 'POST'},
      function (result) {
        if (result.success) {
          opener.goSearch();
          window.location.reload();
        }
      }
    );
  }

  // 삭제 버튼
  function goRemove() {
    // 쿠폰 사용 여부
    if('${info.apply_yn}' === 'Y') {
      alert('사용한 쿠폰은 삭제 할 수 없습니다.');
      return;
    }
    
    var param = {
      cust_svc_coupon_no: $M.getValue('cust_svc_coupon_no'),
    }

    $M.goNextPageAjaxRemove(this_page + '/remove', $M.toGetParam(param), {method: 'POST'},
      function (result) {
        if (result.success) {
          opener.goSearch();
          fnClose();
        }
      }
    );
  }

  // 창 닫기
  function fnClose() {
    window.close();
  }

  // 고객 조회
  function onClickCustInfo() {
    // 고객명 클릭
    $('.cust-tr').hide(); // 테이블 숨김
    formReset(); // 폼 초기화
    openSearchCustPanel('fnSetCustInfo'); // 고객정보 팝업 오픈
  }

  // 고객명 콜백
  function fnSetCustInfo(data) {
    $M.goNextPageAjax(this_page + "/couponSearch", $M.toGetParam({cust_no: data.cust_no}), {
        method: 'GET',
        loader: false
      },
      function (result) {
        if (result.success) {
          if (result.total_cnt <= 0) {
            alert('해당 고객이 보유한 장비에 알맞은 서비스쿠폰 조건이 없습니다.');
            return;
          }
          
          // 쿠폰 리스트 셋팅
          couponList = result.list;

          // 차대번호는 초기화
          bodyNoList = [];

          // 고객 정보 셋팅
          $M.setValue("cust_name", data.real_cust_name);
          $M.setValue("cust_no", data.cust_no);
          $M.setValue('cust_type_name', data.cust_type_name);

          // 쿠폰 selectBox 셋팅
          couponSelectBoxSetting();

          // 임의쿠폰 정보 테이블 show
          $('.cust-step2').show();
        }
      }
    )
  }
  
  // 쿠폰종류 셀렉 박스 셋팅
  function couponSelectBoxSetting() {
    $('#svc_coupon_no').empty();
    $('#svc_coupon_no').append($("<option value=''>- 쿠폰 선택 -</option>"));
    couponList.map(item => {
      var option = $("<option></option>");
      option.val(item.svc_coupon_no);
      option.text(item.svc_coupon_name);
      $('#svc_coupon_no').append(option);
    })
  }
  
  // 쿠폰종류 변경 이벤트
  function onChangeCouponType(value) {
    var param = {
      cust_no : $M.getValue("cust_no"),
      svc_coupon_no: value,
    }

    $M.goNextPageAjax("/cust/cust030502p01" + "/bodyNoSearch", $M.toGetParam(param), {method: 'GET'},
      function (result) {
        if (result.success) {
          // 차대번호 리스트 셋팅
          bodyNoList = result.list;

          // 쿠폰 정보가 있다면
          var coupon = couponList.filter(item => item.svc_coupon_no === value);
          if (coupon.length > 0) {
            // 쿠폰 기간
            var addMonth = isNaN(Number(coupon[0].add_month)) ? 0 : Number(coupon[0].add_month);

            // 발행 날짜, 소멸 날짜 셋팅
            couponDtSetting(addMonth);

            // 차대번호 셀렉 박스 셋팅
            bodyNoSelectBoxSetting();

            // 다음 단계 폼 오픈
            $('.cust-step3').show();
          }
        }
      }
    )
  }

  // 차대번호 셀렉 박스 셋팅
  function bodyNoSelectBoxSetting() {
    $('#body_no').empty();
    $('#body_no').append($("<option value=''>- 차대번호 선택 -</option>"));
    bodyNoList.map(item => {
      var option = $("<option></option>");
      option.val(item.body_no);
      option.text(item.body_no);
      $('#body_no').append(option);
    })
  }
  
  // 쿠폰 날짜 정보 셋팅
  function couponDtSetting(addMonth) {
    var now = "${inputParam.s_current_dt}";
    var issueDt = $M.dateFormat($M.toDate(now), 'yyyyMMdd');
    var expirePlanDt = $M.dateFormat($M.addMonths($M.toDate(now), addMonth), 'yyyyMMdd');

    $M.setValue('issue_dt', issueDt);
    $M.setValue('expire_plan_dt', expirePlanDt);
  }
  
  // 발행일 변경 이벤트
  function onChangeIssueDt() {
    var issueDt = $M.getValue('issue_dt');
    var svcCouponNo = $M.getValue('svc_coupon_no');
    var coupon = couponList.filter(item => item.svc_coupon_no === svcCouponNo);
    if (coupon.length > 0) {
      // 쿠폰 기간
      var addMonth = isNaN(Number(coupon[0].add_month)) ? 0 : Number(coupon[0].add_month);

      // 발행 날짜, 소멸 날짜 셋팅
      var expirePlanDt = $M.dateFormat($M.addMonths($M.toDate(issueDt), addMonth), 'yyyyMMdd');
      $M.setValue('expire_plan_dt', expirePlanDt);
    }
  }

  // 차대번호 변경 이벤트
  function onChangeBodyNo(value) {
    bodyNoList.filter(item => item.body_no === value)?.map(item2 => {
      $M.setValue('machine_seq', item2.machine_seq);
    })
  }

  // 폼 초기화
  function formReset() {
    $('#main_form').each(function () {
      this.reset();
    })
  }

</script>
<body class="bg-white">
<form id="main_form" name="main_form">
  <input type="hidden" id="cust_svc_coupon_no" name="cust_svc_coupon_no" value="${info.cust_svc_coupon_no}"/>
  <input type="hidden" id="auto_yn" name="auto_yn" value="${info.auto_yn}"/>
  <!-- 팝업 -->
  <div class="popup-wrap width-100per">
    <!-- 타이틀영역 -->
    <div class="main-title">
      <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
    </div>
    <!-- /타이틀영역 -->
    <div class="content-wrap">
      <!-- 폼테이블 -->
      <div>
        <div>
          <table class="table-border mt5">
            <colgroup>
              <col width="100px">
              <col width="">
              <col width="100px">
              <col width="">
            </colgroup>
            <tbody>
            <tr>
              <th class="text-right essential-item">고객명</th>
              <td>
                <div class="input-group">
                  <input type="text" class="form-control border-right-0 width100px" id="cust_name" name="cust_name"
                         required="required" readonly="readonly" alt="고객명" value="${info.cust_name}"/>
                  <button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:onClickCustInfo();">
                    <i class="material-iconssearch"></i>
                  </button>
                  <input type="hidden" id="cust_no" name="cust_no" value="${info.cust_no}"/>
                  <c:if test="${info.apply_yn eq 'Y'}">
                    <span class="text-warning ml5">쿠폰 사용 완료</span>
                  </c:if>
                </div>
              </td>
              <th class="text-right essential-item">구분</th>
              <td>
                <input type="text" class="form-control width120px" id="auto_name" name="auto_name" value="${info.auto_name}"
                       disabled="disabled" alt="구분">
              </td>
            </tr>
            <tr class="cust-tr cust-step2">
              <th class="text-right essential-item">쿠폰종류</th>
              <td>
                <select id="svc_coupon_no" name="svc_coupon_no" class="form-control <c:if test="${info.apply_yn eq 'N'}">essential-bg</c:if>" required="required"
                        alt="쿠폰종류"
                        <c:if test="${info.apply_yn eq 'Y'}">disabled="disabled" readonly="true"</c:if>
                        onchange="javascript:onChangeCouponType(this.value);">
                  <option value="">- 쿠폰 종류 -</option>
                </select>
              </td>
              <th class="text-right">회원구분</th>
              <td>
                <input type="text" class="form-control width120px" id="cust_type_name" name="cust_type_name" value="${info.cust_type_name}"
                       disabled="disabled" alt="회원구분">
              </td>
            </tr>

            <tr class="cust-tr cust-step3">
              <th class="text-right essential-item" scope="4">차대번호</th>
              <td colspan="3">
                <input type="hidden" id="machine_seq" value="${info.machine_seq}"/>
                <select id="body_no" name="body_no" class="form-control <c:if test="${info.apply_yn eq 'N'}">essential-bg</c:if>" required="required"
                        alt="차대번호"
                        <c:if test="${info.apply_yn eq 'Y'}">disabled="disabled" readonly="true"</c:if>
                        onchange="javascript:onChangeBodyNo(this.value);"
                >
                  <option value="">- 차대번호 -</option>
                  <c:forEach items="${selectBodyNoList}" var="item">
                    <option value="${item.body_no}" ${item.body_no eq info.body_no ? "selected='selected'" : ""}>${item.body_no}</option>
                  </c:forEach>
                </select>
              </td>
            </tr>
            
            <tr class="cust-tr cust-step3">
              <th class="text-right essential-item">발행일자</th>
              <td>
                <div class="input-group width120px">
                  <input type="text" class="form-control border-right-0 <c:if test="${info.apply_yn eq 'N'}">essential-bg</c:if> calDate" id="issue_dt"
                         name="issue_dt"
                         value="${info.issue_dt}"
                         onChange="javascript:onChangeIssueDt();"
                         <c:if test="${info.apply_yn eq 'Y'}">disabled="disabled" readonly="true"</c:if>
                         required="required" dateformat="yyyy-MM-dd" alt="발행일">
                </div>
              </td>
              <th class="text-right essential-item">소멸예정일</th>
              <td>
                <input type="text" class="form-control width120px" id="expire_plan_dt" 
                       name="expire_plan_dt"
                       value="${info.expire_plan_dt}"
                       disabled="disabled" dateformat="yyyy-MM-dd" alt="소멸예정일">
              </td>
            </tr>
            <tr class="cust-tr cust-step3">
              <th class="text-right">비고</th>
              <td colspan="3">
                <textarea class="form-control" id="remark" name="remark" alt="비고"
                          style="height:50px;" <c:if test="${info.apply_yn eq 'Y'}">disabled="disabled" readonly="true"</c:if>>${info.remark}</textarea>
              </td>
            </tr>
            </tbody>
          </table>
        </div>
      </div>
      <!-- /폼테이블-->
      <div class="btn-group mt10">
        <div class="right">
          <%-- 쿠폰 사용하지 않을 경우에 노출 --%>
          <c:choose>
            <c:when test="${info.apply_yn eq 'N'}">
              <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
                <jsp:param name="pos" value="BOM_R"/>
              </jsp:include>
            </c:when>
            <c:otherwise>
              <button type="button" id="_fnClose" class="btn btn-info" onclick="javascript:fnClose();">닫기</button>
            </c:otherwise>
          </c:choose>
        </div>
      </div>
    </div>
  </div>
  <!-- /팝업 -->
</form>
</body>
</html>