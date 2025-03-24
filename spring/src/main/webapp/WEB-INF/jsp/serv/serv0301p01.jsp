<%@ page contentType="text/html;charset=utf-8" language="java" %><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 쿠폰관리 > 서비스 쿠폰관리 > null > 쿠폰상세
-- [재호] - 3.4차 추가 개발 : 서비스 쿠폰 개편
-- 작성자 : 김상덕
-- 최초 작성일 : 2020-04-07 19:54:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
  <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
  <script type="text/javascript">
    var auiGridLeft;
``
    $(document).ready(function () {
      // AUIGrid 생성
      createAUIGridLeft();

      fnInit();
    });

    function fnInit() {
      fnOutApplyChange($M.getValue("out_apply_yn"));
      fnOutEvtChange($M.getValue("out_evt_yn"));
    }

    // 출하시지급여부에 따라 Form 변화
    function fnOutApplyChange(val) {
      if (val == 'Y') {
        $('.event-tr').show();
      } else {
        $('.event-tr').hide();
      }

      fnOutEvtChange(val == 'N' ? 'N' : $M.getValue("out_evt_yn"));
    }

    // 이벤트 쿠폰 여부에 따라 Form 변화
    function fnOutEvtChange(val) {
      if (val == 'Y') {
        $('.event-step2').show();
        $('.event-step3').show();
      } else {
        $('.event-step2').hide();
        $('.event-step3').hide();
      }
    }

    // 장비쿠폰
    function createAUIGridLeft() {
      var gridPros = {
        rowIdField: "_$uid",
        showRowNumColumn: true,
        // 체크박스 출력 여부
        showRowCheckColumn: true,
        // 전체선택 체크박스 표시 여부
        showRowAllCheckBox: true,
        // 삭제시 취소선 (default true)
        softRemoveRowMode: false
      };
      var columnLayout = [
        {
          headerText: "모델명",
          dataField: "machine_name",
          style: "aui-center",
        },
        {
          dataField: "machine_plant_seq",
          visible: false
        }
      ];
      auiGridLeft = AUIGrid.create("#auiGridLeft", columnLayout, gridPros);
      AUIGrid.setGridData(auiGridLeft, ${coupon.machineCouponList});
      $("#auiGridLeft").resize();
    }

    // 장비 추가
    function fnAddPaid() {
      var param = {
        // "s_maker_cd": $M.getValue("maker_cd")
        // , "machineReadOnlyField": "s_maker_cd"
      };
      openSearchModelPanel('setModelInfo', 'Y', $M.toGetParam(param));
    }

    function setModelInfo(data) {
      var applyModelList = [];
      for (var i in data) {
        // 그리드에 없으면 추가
        if (AUIGrid.getItemsByValue(auiGridLeft, "machine_plant_seq", data[i].machine_plant_seq).length == 0) {
          applyModelList.push({"machine_name": data[i].machine_name, "machine_plant_seq": data[i].machine_plant_seq});
        }
      }
      AUIGrid.addRow(auiGridLeft, applyModelList, 'last');
    }

    // 장비 삭제
    function fnRemove() {
      var checkedItems = AUIGrid.getCheckedRowItemsAll(auiGridLeft);
      if (checkedItems.length == 0) {
        alert("모델을 선택해주세요");
        return;
      }
      var rowIds = [];
      for (var i in checkedItems) {
        rowIds.push(checkedItems[i]._$uid);
      }
      AUIGrid.removeRowByRowId(auiGridLeft, rowIds);
    }

    // 수정
    function goModify() {
      if ($M.validation(document.main_form) == false) {
        return false;
      }

      // 장비쿠폰 세팅
      var machinePlantSeqTemp = AUIGrid.getGridData(auiGridLeft);
      var machinePlantSeqArr = [];
      for (var i in machinePlantSeqTemp) {
        machinePlantSeqArr.push(machinePlantSeqTemp[i].machine_plant_seq);
      }

      if (machinePlantSeqArr.length === 0) {
        alert('적용모델이 정보가 없습니다.');
        return;
      }

      var param = {
        "svc_coupon_no": "${coupon.couponInfo.svc_coupon_no}",
        "svc_coupon_name": $M.getValue("svc_coupon_name"),
        "svc_disp_coupon_name": $M.getValue("svc_disp_coupon_name"),
        "svc_coupon_limit_cd": $M.getValue("svc_coupon_limit_cd"),
        "svc_coupon_img_cd": $M.getValue("svc_coupon_img_cd"),
        "scope_text": $M.getValue("scope_text"),
        "out_apply_yn": $M.getValue("out_apply_yn"),
        "mch_type_cad": $M.getValue("mch_type_cad"),
        "use_yn": $M.getValue("use_yn"),
        "machine_plant_seq_str": $M.getArrStr(machinePlantSeqArr),
        "out_evt_yn": $M.getValue("out_evt_yn"),
        "out_evt_st_dt": $M.getValue("out_evt_st_dt"),
        "out_evt_ed_dt": $M.getValue("out_evt_ed_dt"),
      }
      
      $M.goNextPageAjaxModify("/serv/serv0301/${coupon.couponInfo.svc_coupon_no}" + '/modify', $M.toGetParam(param), {method: 'POST'},
        function (result) {
          if (result.success) {
            window.location.reload();
            window.opener.goSearch();
          }
        }
      );
    }

    // 쿠폰 삭제
    function goRemove() {
      var svc_coupon_no = "${coupon.couponInfo.svc_coupon_no}";
      $M.goNextPageAjaxRemove("/serv/serv0301/" + svc_coupon_no + '/remove', "", {method: 'POST'},
        function (result) {
          if (result.success) {
            fnClose();
            opener.goSearch();
          }
        }
      );
    }

    // 닫기
    function fnClose() {
      window.close();
    }

    // 미리보기
    function goPreview() {
      if($M.getValue("svc_disp_coupon_name") == "") {
        alert("쿠폰표기명을 입력 해주세요.");
        return;
      }

      if($M.getValue("svc_coupon_img_cd") == "") {
        alert("이미지테마를 선택 해주세요.");
        return;
      }

      var param = {
        "svc_disp_coupon_name": $M.getValue("svc_disp_coupon_name"),
        "svc_coupon_img_cd": $M.getValue("svc_coupon_img_cd"),
        "scope_text": $M.getValue("scope_text"),
      }

      var popupOption = "";
      $M.goNextPage('/serv/serv0301p02', $M.toGetParam(param), {popupStatus : popupOption});
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
      <div class="row">
        <div class="col-3">
          <div class="title-wrap">
            <h4>적용모델</h4>
            <div class="right">
              <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
                <jsp:param name="pos" value="MID_L"/>
              </jsp:include>
            </div>
          </div>
          <div id="auiGridLeft" style="margin-top: 5px; height: 300px;"></div>
        </div>
        <div class="col-9">
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
                <th class="text-right essential-item">쿠폰명</th>
                <td>
                  <input type="text" class="form-control" id="svc_coupon_name" name="svc_coupon_name" value="${coupon.couponInfo.svc_coupon_name}"
                         required="required" alt="쿠폰명">
                </td>
                <th class="text-right essential-item">쿠폰표기명</th>
                <td>
                  <input type="text" class="form-control" id="svc_disp_coupon_name" name="svc_disp_coupon_name" value="${coupon.couponInfo.svc_disp_coupon_name}"
                         required="required" alt="쿠폰표기명">
                </td>
              </tr>
              <tr>
                <th class="text-right essential-item">유효기간</th>
                <td>
                  <select class="form-control width100px" id="svc_coupon_limit_cd" name="svc_coupon_limit_cd"
                          required="required"
                          alt="유효기간">
                    <c:forEach items="${codeMap['SVC_COUPON_LIMIT']}" var="item">
                      <option value="${item.code_value}" <c:if test="${item.code_value eq coupon.couponInfo.svc_coupon_limit_cd}">selected</c:if>>${item.code_name}</option>
                    </c:forEach>
                  </select>
                </td>
                <th class="text-right essential-item">이미지테마</th>
                <td>
                  <select class="form-control width100px" id="svc_coupon_img_cd" name="svc_coupon_img_cd"
                          required="required"
                          alt="이미지테마">
                    <c:forEach items="${codeMap['SVC_COUPON_IMG']}" var="item">
                      <option value="${item.code_value}" <c:if test="${item.code_value eq coupon.couponInfo.svc_coupon_img_cd}">selected</c:if>>${item.code_name}</option>
                    </c:forEach>
                  </select>
                </td>
              </tr>
              <tr>
                <th class="text-right">포함범위</th>
                <td colspan="3">
                  <input type="text" class="form-control" id="scope_text" name="scope_text" alt="포함범위" value="${coupon.couponInfo.scope_text}">
                </td>
              </tr>
              <tr>
                <th class="text-right essential-item">사용여부</th>
                <td>
                  <div class="form-check form-check-inline">
                    <input class="form-check-input" type="radio" name="use_yn" id="use_y" value="Y" alt="사용여부"
                           required="required" <c:if test="${'Y' eq coupon.couponInfo.use_yn}">checked</c:if>>
                    <label class="form-check-label" for="use_y">Y</label>
                  </div>
                  <div class="form-check form-check-inline">
                    <input class="form-check-input" type="radio" name="use_yn" id="use_n" value="N"
                           required="required" <c:if test="${'N' eq coupon.couponInfo.use_yn}">checked</c:if>>
                    <label class="form-check-label" for="use_n">N</label>
                  </div>
                </td>
                <th class="text-right essential-item">장비계약구분</th>
                <td>
                  <div class="form-check form-check-inline">
                    <input class="form-check-input" type="radio" id="mch_type_c" name="mch_type_cad" value="C" alt="장비계약" required="required"
                           <c:if test="${'C' eq coupon.couponInfo.mch_type_cad}">checked</c:if>
                    >
                    <label for="mch_type_c" class="form-check-label">건설기계</label>
                  </div>
                  <div class="form-check form-check-inline">
                    <input class="form-check-input" type="radio" id="mch_type_a" name="mch_type_cad" value="A" required="required" alt="장비계약"
                           <c:if test="${'A' eq coupon.couponInfo.mch_type_cad}">checked</c:if>
                    >
                    <label for="mch_type_a" class="form-check-label">농기계</label>
                  </div>
                </td>
              </tr>
              <tr>
                <th class="text-right essential-item">출하시지급여부</th>
                <td colspan="3">
                  <div class="form-check form-check-inline">
                    <input class="form-check-input" type="radio" name="out_apply_yn" id="out_apply_y" value="Y" onchange="fnOutApplyChange(this.value)"
                           alt="출하시지급여부" required="required" <c:if test="${'Y' eq coupon.couponInfo.out_apply_yn}">checked</c:if>
                    >
                    <label class="form-check-label" for="out_apply_y">Y</label>
                  </div>
                  <div class="form-check form-check-inline">
                    <input class="form-check-input" type="radio" name="out_apply_yn" id="out_apply_n" value="N" onchange="fnOutApplyChange(this.value)"
                           required="required" <c:if test="${'N' eq coupon.couponInfo.out_apply_yn}">checked</c:if>>
                    <label class="form-check-label" for="out_apply_n">N</label>
                  </div>
                </td>
              </tr>
              <tr class="event-tr event-step1">
                <th class="text-right">이벤트쿠폰 여부</th>
                <td colspan="3">
                  <div class="form-check form-check-inline">
                    <input class="form-check-input" type="radio" name="out_evt_yn" id="out_evt_y" value="Y" onchange="fnOutEvtChange(this.value)"
                           alt="이벤트쿠폰여부" required="required" <c:if test="${'Y' eq coupon.couponInfo.out_evt_yn}">checked</c:if>
                    >
                    <label class="form-check-label" for="out_evt_y">Y</label>
                  </div>
                  <div class="form-check form-check-inline">
                    <input class="form-check-input" type="radio" name="out_evt_yn" id="out_evt_n" value="N" onchange="fnOutEvtChange(this.value)"
                           required="required" <c:if test="${'N' eq coupon.couponInfo.out_evt_yn}">checked</c:if>>
                    <label class="form-check-label" for="out_evt_n">N</label>
                  </div>
                </td>
              </tr>
              <tr class="event-tr event-step2">
                <th class="text-right">이벤트 시작일자</th>
                <td colspan="3">
                  <div class="input-group width100px">
                    <input type="text" class="form-control border-right-0 calDate" id="out_evt_st_dt" name="out_evt_st_dt" dateFormat="yyyy-MM-dd" value="${coupon.couponInfo.out_evt_st_dt}"  alt="이벤트시작일자">
                  </div>
                </td>
              </tr>
              <tr class="event-tr event-step3">
                <th class="text-right">이벤트 종료일자</th>
                <td colspan="3">
                  <div class="input-group width100px">
                    <input type="text" class="form-control border-right-0 calDate" id="out_evt_ed_dt" name="out_evt_ed_dt" dateFormat="yyyy-MM-dd" value="${coupon.couponInfo.out_evt_ed_dt}" alt="이벤트종료일자">
                  </div>
                </td>
              </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
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