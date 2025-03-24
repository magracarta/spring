<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 자산 > 은행거래조건관리 > null > null
-- 작성자 : 손광진
-- 최초 작성일 : 2020-04-13 16:27:57
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		$(document).ready(function() {
			createLeftAUIGrid();	// 그리드 생성 (은행목록)
			createRightAUIGrid();	// 그리드 생성 (처리내역)
			goSearch();				// 은행목록 조회
		});
		
		function goSetting() {
			var popupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=900, height=550, left=0, top=0";
			$M.goNextPage("/acnt/acnt0503p01", "", {popupStatus : popupOption});
		}	
		
		function goSearch() {
			var param = {
				"s_sort_key" 		: "sort_no",
				"s_sort_method" 	: "asc"
			};
			
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : "get"},
				function(result) {
					if(result.success) {
						$("#total_cnt_bank").html(result.total_cnt);
						AUIGrid.setGridData(auiGridLeft, result.list);
					};
				}
			);
		}
		
		// 처리내역 조회
		function goSearchDealList(getParam) {
			// 은행코드 체크
			if(checkBankCode(getParam) === false) {
				alert("선택된 은행이 없습니다.");		
				return;
			};
			var s_code = getParam;
			var param = {
				"s_code" : s_code,
				"s_sort_key" : "b.reg_dt",
				"s_sort_method" : "desc",
			};
			
			$M.goNextPageAjax(this_page + "/searchBankDeal", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						// 데이터 그리드 세팅
						AUIGrid.setGridData(auiGridRight, result.list);
						$("#total_cnt_bank_deal").html(result.total_cnt);
					};
				}	
			);
		}
		
		// 처리내역 행 추가
		function fnAdd() {
			var bankCode = $M.getValue("bankCode");
			
			// 은행코드 체크
			if(checkBankCode(bankCode) === false) {
				alert("선택된 은행이 없습니다.");		
				return;
			};

			// 그리드 빈값 체크
			if(fnCheckGridEmpty(auiGridRight)) {
	    		var item = new Object();
	    		item.bank_deal_seq = -1; // 신규생성 시 -1
	    		item.bank_cd = bankCode;
	    		item.reg_dt = "";
	    		item.amt = "";
	    		item.rate = "";
	    		item.deal_type = "";
	    		item.remark = "";
				AUIGrid.addRow(auiGridRight, item, "first");
			};
		}
		
		// 은행거래조건 저장
		function goSave() {
			if (fnChangeGridDataCnt(auiGridRight) == 0) {
				alert("변경된 데이터가 없습니다.");
				return false;
			};
			
			if (fnCheckGridEmpty() === false) {
				alert("필수 항목은 반드시 값을 입력해야합니다.");
				return false;
			};
			
			var frm = fnChangeGridDataToForm(auiGridRight);
			console.log(frm);
			$M.goNextPageAjaxSave(this_page + "/save", frm, {method : "POST"}, 
				function(result) {
					if(result.success) {
						AUIGrid.removeSoftRows(auiGridRight);
						AUIGrid.resetUpdatedItems(auiGridRight);
					};
				}
			); 
		}
		
		// 은행코드 체크
		function checkBankCode(value) {
			var bankCode = $M.nvl(value, -1);
			var result = false;
			// 은행코드 체크
			if( bankCode == -1 || bankCode.length != 3 ) {
				result = false;
			} else {
				result = true;
			};
			return result;
		};
		
		// 그리드 빈값 체크
		function fnCheckGridEmpty() {
			return AUIGrid.validateGridData(auiGridRight, ["reg_dt", "amt", "rate"], "필수 항목은 반드시 값을 입력해야합니다.");
		}
		
		
		// #################### 그리드 생성 영역  ####################
		
		// 그리드생성
		function createLeftAUIGrid() {
			var gridPros = {
				rowIdField : "code",
				showRowNumColumn : true,
				fillColumnSizeMode : false,
				enableFilter :true,
				height : 580
			};
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
				    headerText: "은행명",
				    dataField: "code_name",
					width : "95",
					minWidth : "95",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "지점명",
					dataField : "code_v1",
					width : "100",
					minWidth : "100",
					style : "aui-center aui-link",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "연락처",
					dataField : "code_v2",
					width : "147",
					minWidth : "147",
					style : "aui-center"
				},
				{
					headerText : "LC한도",
					dataField : "code_v3",
					dataType : "numeric",
					formatString : "#,##0",
					width : "90",
					minWidth : "90",
					style : "aui-right"
				},
				{
					headerText : "사용여부",
					dataField : "use_yn",
					width : "70",
					minWidth : "70",
					style : "aui-center",
					filter : {
						showIcon : true
					},
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						return item["use_yn"] == "Y" ? "사용" : "미사용";
					}
				}
			];
			auiGridLeft = AUIGrid.create("#auiGridLeft", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridLeft, []);
			// 클릭한 셀 데이터 받음
 			AUIGrid.bind(auiGridLeft, "cellClick", function(event) {
				if(event.dataField == "code_v1" ) {
	 				var frm = document.main_form;
	 				$M.setValue(frm, "bankName", event.item.code_name);
	 				$M.setValue(frm, "bankCode", event.item.code);
	 				$M.setValue(frm, "areaName", event.item.code_v1);
	 				$M.setValue(frm, "hpNo", event.item.code_v2);
	 				$M.setValue(frm, "lcLimit", event.item.code_v3);
					// 해당 은행의 처리내역 조회
	 				var s_code = event.item.code;	// 은행코드
					goSearchDealList(s_code);
				}
			});
		}
		
		
		// 그리드생성
		function createRightAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn : true,
				fillColumnSizeMode : false,
				editable : true,
				showStateColumn : false,
				height : 465
			};
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
					headerText : "등록일자", 
					dataField : "reg_dt", 
					dataType : "date",   
					width : "80",
					minWidth : "80",
					style : "aui-center aui-editable",
					dataInputString : "yyyymmdd",
					formatString : "yy-mm-dd",
					editRenderer : {
						type : "JQCalendarRenderer", // datepicker 달력 렌더러 사용
						defaultFormat : "yyyymmdd", // 원래 데이터 날짜 포맷과 일치 시키세요. (기본값: "yyyy/mm/dd")
						onlyCalendar : false, // 사용자 입력 불가, 즉 달력으로만 날짜입력 ( 기본값: true )
						maxlength : 8,
						onlyNumeric : true, // 숫자만
						validator : function(oldValue, newValue, rowItem) { // 에디팅 유효성 검사
							return fnCheckDate(oldValue, newValue, rowItem);
						},
						showEditorBtnOver : true
					},
				},
				{
					headerText : "금액",
					dataField : "amt",
					width : "95",
					minWidth : "95",
					style : "aui-right aui-editable",
					dataType : "numeric",
					formatString : "#,##0",
					editRenderer : {
					    type : "InputEditRenderer",
					    onlyNumeric : true
					}
				},
				{
					headerText : "이율",
					dataField : "rate",
					editRenderer : {
				    	type : "InputEditRenderer",
				      	onlyNumeric : true,
				      	allowPoint : true,  // 소수점( . ) 도 허용할지 여부
				      	maxlength : 4,
				      	// 에디팅 유효성 검사
				      	validator : AUIGrid.commonValidator
					},
					width : "70",
					minWidth : "70",
					style : "aui-right aui-editable"
				},
				{
					headerText : "구분",
					dataField : "deal_type",
					width : "115",
					minWidth : "115",
					style : "aui-center aui-editable"
				},
				{
					headerText : "비고",
					dataField : "remark",
					width : "325",
					minWidth : "325",
					style : "aui-left aui-editable"
				},
				{
					headerText : "은행코드",
					dataField : "bank_cd",
					style : "aui-left",
					visible : false,
					editable : false
				},
				{
					headerText : "삭제", 
					dataField : "bank_deal_seq", 
					width : "55",
					minWidth : "55",
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
							var isRemoved = AUIGrid.isRemovedById(auiGridRight);
							if (isRemoved == false) {
								AUIGrid.removeRow(event.pid, event.rowIndex);		
							} else {
								AUIGrid.restoreSoftRows(auiGridRight, "selectedIndex"); 
							};
						},
					},
					labelFunction : function(rowIndex, columnIndex, value, headerText, item){
				    	return '삭제'
				    },
					style : "aui-center",
					editable : false
				}
			];
			auiGridRight = AUIGrid.create("#auiGridRight", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridRight, []);
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
							<div class="row">
								<div class="col-5">
									<div id="auiGridLeft" style="margin-top: 5px;"></div>
									<div class="btn-group mt5">
										<div class="left">
											총 <strong class="text-primary" id="total_cnt_bank">0</strong>건
										</div>	
										<div class="right">
											<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_M"/></jsp:include>
										</div>	
									</div>
								</div>
								<div class="col-7">
								<!-- 폼테이블 -->				
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
													<th class="text-right">은행명</th>
													<td>
														<input type="text" class="form-control text-left width120px" id="bankName" name="bankName" readonly>
														<input type="hidden" class="form-control text-left width120px" id="bankCode" name="bankCode" readonly>
													</td>
													<th class="text-right">연락처</th>
													<td>
														<input type="text" class="form-control text-left width140px" id="hpNo" name="hpNo" readonly>
													</td>
												</tr>
												<tr>
													<th class="text-right">지점명</th>
													<td>
														<input type="text" class="form-control text-left width120px" id="areaName" name="areaName" readonly>
													</td>
													<th class="text-right">LC한도</th>
													<td>
														<div class="form-row inline-pd widthfix">
															<div class="col width100px">
																<input type="text" class="form-control text-right" id="lcLimit" name="lcLimit" readonly>
															</div>
															<div class="col width22px">원</div>
														</div>
													</td>
												</tr>																						
											</tbody>
										</table>
									</div>
									<!-- /폼테이블 -->	
									<!-- 처리내역 -->
									<div>
										<div class="title-wrap mt10">
											<h4>처리내역</h4>
											<div class="btn-group">
												<div class="right">
													<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
												</div>
											</div>
										</div>
										<div id="auiGridRight" style="margin-top: 5px;"></div>
										<div class="btn-group mt5">
											<div class="left">
												총 <strong class="text-primary" id="total_cnt_bank_deal">0</strong>건
											</div>	
											<div class="right">
												<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
											</div>	
										</div>	
									</div>	
									<!-- /처리내역 -->							
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