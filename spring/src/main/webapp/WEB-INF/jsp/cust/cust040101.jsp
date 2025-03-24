<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 고객관리 > 고객센터 > 고객불만접수 > null
-- 작성자 : 성현우
-- 최초 작성일 : 2020-03-17 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		// 직원조회 결과
		function fnSetMemberInfo(data) {
			$M.setValue("assign_mem_name", data.mem_name);
			$M.setValue("assign_mem_no", data.mem_no);
		}

		function fnSetDeviceHis(data) {
			$M.setValue("machine_seq", data.machine_seq);
			$M.setValue("body_no", data.body_no);
			$M.setValue("machine_name", data.machine_name);

			$M.setValue("cust_no", data.cust_no);
			$M.setValue("cust_name", data.real_cust_name);
			$M.setValue("cust_hp_no", fnGetHPNum(data.real_hp_no));
			$M.setValue("sale_mem_name", data.sale_mem_name);
			$M.setValue("out_dt", data.out_dt);
			$M.setValue("center_org_code", data.center_org_code);
			$M.setValue("center_org_name", data.center_org_name);
		}

		function goSearchMemberPopup() {

			var param = {
				"s_org_code" : ${SecureUser.org_code}
			};

			openSearchMemberPanel('fnSetMemberInfo', $M.toGetParam(param));
		}

		// 고객팝업 클릭 후 리턴
		function fnSetCustInfo(data) {
			
			$M.setValue("machine_seq", data.machine_seq);
			$M.setValue("body_no", data.body_no);
			$M.setValue("machine_name", data.machine_name);

			$M.setValue("cust_no", data.cust_no);
			$M.setValue("cust_name", data.real_cust_name);
			$M.setValue("cust_hp_no", fnGetHPNum(data.real_hp_no));
			$M.setValue("sale_mem_name", data.sale_mem_name);
			$M.setValue("out_dt", data.out_dt);
			$M.setValue("center_org_code", data.center_org_code);
			$M.setValue("center_org_name", data.center_org_name);

			fnSearch(data);
		}

		// 장비정보
		function fnSearch(data) {
            var param = {
                "machine_seq": data.machine_seq
            };

            $M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: 'GET'},
                function (result) {
                    if (result.success) {
                    	fnDataSetting(result.bean);
                    }
                }
            );
		}

		function fnDataSetting(data) {
			$M.setValue("out_dt", data.out_dt);
		}

		// 저장
		function goSave() {
			var frm = document.main_form;

			// validation check
			if($M.validation(frm,
					{field:["cust_no", "receipt_org_code", "assign_mem_no", "req_memo"]}) == false) {
				return;
			};

			$M.goNextPageAjaxSave(this_page + '/save', $M.toValueForm(frm), {method : 'POST'},
				function(result) {
					if(result.success) {
						alert("저장이 완료되었습니다.");
						fnList();
					}
				}
			);
		}

		// 거래원장
		function goLedgerPopUp() {
			var custNo = $M.getValue("cust_no");
			
			if(custNo == "") {
				alert("고객을 먼저 선택해주세요.");
				return false;
			}
			
			var param = {
				"s_cust_no" : custNo
			};

			openDealLedgerPanel($M.toGetParam(param));
		}
		
		function fnSendSms() {
			var param = {
				"name" : $M.getValue("cust_name"),
				"hp_no" : $M.getValue("cust_hp_no")
			};

			openSendSmsPanel($M.toGetParam(param));
		}
		
		// 수리내역
		function fixInfo() {
			// 보낼 데이터
			var machineSeq = $M.getValue("machine_seq");
			
			if(machineSeq == "") {
				alert("장비를 먼저 선택해주세요.");
				return false;
			}
			
			var params = {
				"s_machine_seq" : machineSeq
			};
			var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1400, height=920, left=0, top=0";
			$M.goNextPage('/comp/comp0506', $M.toGetParam(params), {popupStatus : popupOption});
		}

		
		function fnList() {
			history.back();
		}
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<input  type="hidden" id="machine_seq" name="machine_seq">
<div class="layout-box">
<!-- contents 전체 영역 -->
	<div class="content-wrap">
		<div class="content-box">
<!-- 상세페이지 타이틀 -->
			<div class="main-title detail">
				<div class="detail-left">
					<button type="button" class="btn btn-outline-light" onclick="javascript:fnList()"><i class="material-iconskeyboard_backspace text-default"></i></button>
					<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
				</div>
			</div>
<!-- /상세페이지 타이틀 -->
			<div class="contents">
<!-- 폼테이블 -->	
			<%-- 컨텐츠 내용 넣어주세요. --%>
				<div>
					<table class="table-border">
						<colgroup>
							<col width="100px">
							<col width="">
							<col width="100px">
							<col width="">
							<col width="100px">
							<col width="">
							<col width="100px">
							<col width="">
						</colgroup>
						<tbody>
						<tr>
							<th class="text-right">접수일자</th>
							<td>
								<div class="input-group">
									<input type="text" class="form-control border-right-0 calDate" dateFormat="yyyy-MM-dd" disabled="disabled" required="required" alt="접수일자" readonly="readonly" id="current" name="current" value="${inputParam.s_current_dt}"> <!- 접수일자 수정못하게 변경 -->
							</td>
							<th class="text-right">접수자</th>
							<td>
								<input type="text" class="form-control width140px" required="required" alt="접수자명" readonly="readonly" value="${SecureUser.user_name}">
								<input type="hidden" name="mem_no" id="mem_no" required="required" alt="접수자명" value="${SecureUser.mem_no}">
							</td>
							<th class="text-right">접수부서</th>
							<td>
								<input type="text" class="form-control width140px" name="receipt_org_name" id="receipt_org_name" value="${SecureUser.org_name}" readonly="readonly" alt="부서명">
								<input type="hidden" name="receipt_org_code" id="receipt_org_code" value="${SecureUser.org_code}" >
							</td>
							<th class="text-right essential-item">처리자지정</th>
							<td>
								<div class="input-group">
									<input type="text" class="form-control border-right-0 essential-bg width110px" name="assign_mem_name" id="assign_mem_name" readonly="readonly" value="${SecureUser.user_name}">
									<input type="hidden" name="assign_mem_no" id="assign_mem_no" alt="처리자지정" required="required" value="${SecureUser.mem_no}" >
									<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:goSearchMemberPopup()"><i class="material-iconssearch"></i></button>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right essential-item">고객명</th>
							<td>
								<div class="form-row inline-pd">
								<div class="col-auto">
									<div class="input-group">
									<input type="text" class="form-control essential-bg width120px" name="cust_name" id="cust_name" required="required" alt="고객명" readonly="readonly">
									<input type="hidden" name="cust_no" id="cust_no" required="required" alt="고객명">
									<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openSearchCustPanel('fnSetCustInfo')"><i class="material-iconssearch"></i></button>
									</div>
								</div>
								<div class="col-auto">
									<button type="button" class="btn btn-primary-gra" style="width: 100%;" onclick="javascript:goLedgerPopUp()">고객원장</button>
								</div>
							</div>
							</td>
							<th class="text-right">휴대폰</th>
							<td>
								<div class="input-group width140px">
									<input type="text" class="form-control width140px border-right-0" name="cust_hp_no" id="cust_hp_no" readonly="readonly">
									<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnSendSms();"><i class="material-iconsforum"></i></button>
								</div>
							</td>
<%--							<th class="text-right">영업담당</th>--%>
<%--							<td>--%>
<%--								<input type="text" class="form-control width140px" name="sale_mem_name" id="sale_mem_name" readonly="readonly">--%>
<%--							</td>--%>
							<th class="text-right">담당센터</th>
							<td>
								<input type="text" class="form-control width140px" name="center_org_name" id="center_org_name" readonly="readonly">
								<input type="hidden" id="center_org_code" name="center_org_code">
							</td>
							<th class="text-right">처리자</th>
							<td>
								<input type="text" class="form-control width140px" id="proc_mem_name" name="proc_mem_name" readonly="readonly">
								<input type="hidden" id="proc_mem_no" name="proc_mem_no">
							</td>
						</tr>
						<tr>
							<th class="text-right">차대번호</th>
							<td>
								<div class="input-group">
									<input type="text"  id="body_no" name="body_no" class="form-control border-right-0 width240px">
									<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openSearchDeviceHisPanel('fnSetDeviceHis');"><i class="material-iconssearch"></i></button>
								</div>
							</td>
							<th class="text-right">장비명</th>
							<td>
								<div class="form-row inline-pd">
								<div class="col-auto">
									<input type="text" class="form-control width140px" id="machine_name" name="machine_name" readonly="readonly">
								</div>
								<div class="col-auto">
									<button type="button" class="btn btn-primary-gra" style="width: 100%;" onclick="javascript:fixInfo()">수리내역</button>
								</div>
							</div>
							</td>
							<th class="text-right">출고일자</th>
							<td>
								<input type="text" class="form-control width140px" readonly="readonly" id="out_dt" name="out_dt" dateFormat="yyyy-MM-dd" >
							</td>
							<th class="text-right">처리일시</th>
							<td>
								<input type="text" id="proc_date " name="proc_date" class="form-control width140px" readonly="readonly">
							</td>
						</tr>
						<tr>
							<th class="text-right essential-item">접수내용</th>
							<td colspan="7">
								<textarea id="req_memo" name="req_memo" required="required" alt="접수내용" style="height: 250px;"></textarea>
							</td>
						</tr>
						<tr>
							<th class="text-right">처리내용</th>
							<td colspan="7">
								<textarea id="resp_memo" name="resp_memo" style="height: 100px;"></textarea>
							</td>
						</tr>
						</tbody>
					</table>
				</div>
				<div class="btn-group mt10">
					<div class="right"><%-- 버튼위치는 pos param 에 따라 나옴 (없으면 기본 상단나옴) T_CODE.CODE_VALUE='BTN_POS' 참고 --%>
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
					</div>
				</div>
<!-- /폼테이블 -->	
			</div>						
		</div>		
	</div>
<!-- /contents 전체 영역 -->	
</div>
</form>	
</body>
</html>