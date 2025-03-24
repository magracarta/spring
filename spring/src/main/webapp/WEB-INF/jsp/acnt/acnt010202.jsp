<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 비용관리 > 전도금정산서 > null > null
-- 작성자 : 김태훈
-- 최초 작성일 : 2020-04-08 17:55:01
-- 카드매출내역
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		var auiGrid;
		$(document).ready(function() {
			createAUIGrid();
			fnInit();
		});

		
		function fnInit() {
			var now = "${inputParam.s_current_dt}";
			$M.setValue("s_start_dt", $M.addDates($M.toDate(now), -7));
			if ("${page.fnc.F00673_001}" == "Y" ) {
				$("#_goConfirmProcess").css("display", "none");
			} else {
				$("#_goAccTrans").css("display", "none");
				$("#_goCancelAccTrans").css("display", "none");
			}
		}
		
		function fnUpdateParentDtAnGoSearch() {
			var value = $M.getValue("s_start_dt");
		    $('#s_start_dt', window.parent.document).val(value);
		    var value = $M.getValue("s_end_dt");
			$('#s_end_dt', window.parent.document).val(value);
			if ($M.getValue("s_org_code") != "") {
				goSearch();
			}
		}
		
		function fnUpdateParentStartDt() {
			var value = $M.getValue("s_start_dt");
		    $('#s_start_dt', window.parent.document).val(value);
		}
		
		function fnUpdateParentEndDt() {
			var value = $M.getValue("s_end_dt");
			$('#s_end_dt', window.parent.document).val(value);
		}
		
		function fnUpdateParentOrgCode() {
			var value = $M.getValue("s_org_code");
			$('#s_org_code', window.parent.document).val(value);
		}
		
		function fnUpdateParentImprestCd() {
			var value = $M.getValue("s_imprest_status_cd");
			$('#s_imprest_status_cd', window.parent.document).val(value);
		}
		
		function fnUpdateParentExcept() {
			$('#s_except_acnt_confirm', window.parent.document).prop('checked', $("#s_except_acnt_confirm").prop("checked"));
		}

		function goSearch() {
			if ($M.validation(document.main_form) == false) {
				return;
			};
			if($M.checkRangeByFieldName('s_start_dt', 's_end_dt', true) == false) {				
				return;
			}; 
			var param = {
				s_start_dt : $M.getValue("s_start_dt"),
				s_end_dt : $M.getValue("s_end_dt"),
				s_org_code : $M.getValue("s_org_code"),
				s_imprest_status_cd : $M.getValue("s_imprest_status_cd"),
				s_sort_key : "id.inout_doc_no",
				s_sort_method : "asc"
			};
			_fnAddSearchDt(param, 's_start_dt', 's_end_dt');
			console.log(param);
			$M.goNextPageAjax("/acnt/acnt0102/cardSale/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						$("#total_cnt").html(result.total_cnt);
						AUIGrid.setGridData(auiGrid, result.list);
					};
				}
			);
		}

		function goConfirmProcess() {
			var items = AUIGrid.getCheckedRowItemsAll(auiGrid);
			if (items.length == 0) {
				alert("체크된 데이터가 없습니다.");
				return false
			}
			var param = {
				inout_doc_no_str : $M.getArrStr(items, {key : 'inout_doc_no'}),
			}
			var msg = "확정처리하시겠습니까?";
			$M.goNextPageAjaxMsg(msg, "/acnt/acnt0102/cardSale/confirm", $M.toGetParam(param), {method : 'POST'}, 
				function(result) {
					if(result.success) {
						for (var i = 0; i < items.length; ++i) {
							var param = {
								imprest_status_cd : "2",
								imprest_status_name : "발송",
								inout_doc_no : items[i].inout_doc_no
							};
							var index = AUIGrid.rowIdToIndex(auiGrid, items[i].inout_doc_no);
							AUIGrid.updateRow(auiGrid, param, index);
						}
						AUIGrid.removeSoftRows(auiGrid);
						AUIGrid.resetUpdatedItems(auiGrid);
					};
				}
			);
		}

		function fnDownloadExcel() {
			fnExportExcel(auiGrid, "카드매출내역", "");
		}

		function createAUIGrid() {
			var gridPros = {
				// 체크박스 출력 여부
				showRowCheckColumn : true,
				rowIdField : "inout_doc_no",
				// 전체선택 체크박스 표시 여부
				showRowAllCheckBox : true,
				// Row번호 표시 여부
				showRowNumColum : true,
				showFooter : true,
				footerPosition : "top",
			};

			var columnLayout = [
				{
					headerText : "전표번호",
					dataField : "inout_doc_no",
					style : "aui-center aui-popup"
				},
				{
					headerText : "고객명",
					dataField : "cust_name",
					style : "aui-center aui-popup"
				},
				{
					headerText : "상호",
					dataField : "breg_name"
				},
				{
					headerText : "구분",
					width : "5%",
					dataField : "inout_type_name"
				},
				{
					headerText : "내용",
					width : "15%",
					dataField : "view_remark",
					style : "aui-left"
				},
				{
					headerText : "물품대",
					dataField : "inout_amt",
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0"
				},
				{
					headerText : "할인액",
					dataField : "discount_amt",
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0"
				},
				{
					headerText : "합계",
					dataField : "total_amt",
					dataType : "numeric",
					style : "aui-right",
					formatString : "#,##0"
				},
				{
					headerText : "입(출)금액",
					dataField : "total_amt",
					dataType : "numeric",
					style : "aui-right",
					formatString : "#,##0"
				},
				{
					headerText : "작성자",
					width : "5%",
					dataField : "mem_name"
				},
				{
					headerText : "상태",
					dataField : "imprest_status_name",
					editable : false, // 그리드의 에디팅 사용 안함( 템플릿에서 만든 Select 로 에디팅 처리 하기 위함 )
					renderer : { // HTML 템플릿 렌더러 사용
						type : "TemplateRenderer"
					}, 
					// dataField 로 정의된 필드 값이 HTML 이라면 labelFunction 으로 처리할 필요 없음.
					labelFunction : function (rowIndex, columnIndex, value, headerText, item ) { // HTML 템플릿 작성
						var template = '<div>';
						if (value != "" && value != undefined) {
							template+= "<button class='btn btn-default'>"+value+"</button>";
						}
						template += '</div>';
						return template;
					}
				},
				{
					dataField : "imprest_status_cd",
					visible : false
				},
				{
					dataField : "inout_type_cd",
					visible : false
				},
				{
					dataField : "account_link_cd",
					visible : false
				},
				{
					dataField : "end_yn",
					visible : false
				},
				{
					dataField : "duzon_trans_yn",
					visible : false
				},
				{
					dataField : "cust_no",
					visible : false
				}
			];

			// 푸터 설정
			var footerLayout = [
				{
					labelText : "합계",
					style : "aui-center",
					positionField : "view_remark"
				},
				{
					dataField: "inout_amt",
					positionField: "inout_amt",
					operation: "SUM",
					formatString : "#,##0",
					style: "aui-right aui-footer"
				},
				{
					dataField: "discount_amt",
					positionField: "discount_amt",
					operation: "SUM",
					formatString : "#,##0",
					style: "aui-right aui-footer"
				},
				{
					dataField: "total_amt",
					positionField: "total_amt",
					operation: "SUM",
					formatString : "#,##0",
					style: "aui-right aui-footer"
				},
				{
					dataField: "total_amt",
					positionField: "total_amt",
					operation: "SUM",
					formatString : "#,##0",
					style: "aui-right aui-footer"
				}
			];

			// 실제로 #grid_wrap에 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 푸터 레이아웃 세팅
			AUIGrid.setFooter(auiGrid, footerLayout);
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, []);
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(event.dataField == "cust_name" ) {
					// 거래원장상세
					var params = {
						"s_cust_no" : event.item["cust_no"],
						"s_start_dt" : $M.getValue("s_start_dt"),
						"s_end_dt" : $M.getValue("s_end_dt"),
						"s_ledger_yn" : "Y"
					};
					openDealLedgerPanel($M.toGetParam(params));

				}

				if(event.dataField == "inout_doc_no") {
					var param = {
						inout_doc_no : event.item.inout_doc_no
					}
					var poppupOption = "scrollbars=yes, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=400, left=0, top=0";
					$M.goNextPage('/cust/cust0203p01', $M.toGetParam(param), {popupStatus : poppupOption});
				} else if (event.dataField == "imprest_status_name") {
					console.log(event);
					var nowCd = event.item.imprest_status_cd;
					var param = {
						inout_doc_no : event.item.inout_doc_no,
					};
					if ("${page.fnc.F00673_001}" == "Y") {
						if (nowCd == "3") {
							param['imprest_status_cd'] = "2";
							param['imprest_status_name'] = "발송";
						} else {
							param['imprest_status_cd'] = "3";
							param['imprest_status_name'] = "수신";
						}
					} else {
						// 관리부가 아니면 수신과 발송 상태로 되있는건 변경 불가, 오직 확인과 미확인만
						if (nowCd == "1") {
							param['imprest_status_cd'] = "0";
							param['imprest_status_name'] = "미확인";
						} else if (nowCd == "0") {
							param['imprest_status_cd'] = "1";
							param['imprest_status_name'] = "확인";
						} else {
							return false;
						}
					}
					$M.goNextPageAjax("/acnt/acnt0102/cardSale/status", $M.toGetParam(param), {method : 'POST', loader : false}, 
						function(result) {
							if(result.success) {
								/* AUIGrid.addCheckedRowsByValue(auiGrid, "inout_doc_no", event.item.inout_doc_no); */
								AUIGrid.updateRow(auiGrid, param, event.rowIndex);
							};
						}
					);
				}
			});
		}
		
		// 21.09.09 (SR : 11682) 카드매출내역탭에서 회계전송가능하도록 수정
		// 회계전송
		function goAccTrans() {
			// account_link_cd가 있어야 회계전송 가능
			// row행의 회계거래처코드가 없습니다.
			var row = "";
			var items = AUIGrid.getCheckedRowItemsAll(auiGrid);
			var gridData = AUIGrid.getGridData(auiGrid);
			
			if (items.length == 0) {
				alert("체크된 데이터가 없습니다.");
				return false
			}
			
			for (var i = 0; i < items.length; i++) {
				if(items[i].end_yn != "Y") {
					alert("마감처리된 건만 회계처리가 가능합니다.");
					return false;
				}
				if(items[i].duzon_trans_yn == "Y") {
					alert("회계처리된 데이터가 있습니다.");
					return false;
				}
				if(items[i].account_link_cd == "") {
					for(var j = 0; j < gridData.length; j++) {
						if(items[i].inout_doc_no == gridData[j].inout_doc_no) {
							row = j + 1;
						}
					}
					alert(row + "행의 회계거래처코드가 없습니다.");
					return false;
				}

				// 2022-11-24 (SR: 14336) 매출전표일경우 조건 추가. (카드매출,현금영수증 추가)
                if(items[i].inout_type_cd == "04") {
					if((items[i].vat_treat_cd == "N" || items[i].vat_treat_cd == "A" || items[i].vat_treat_cd == "C") == false) {
						alert("매출전표일 경우 회계전송은 카드매출/현금영수증/무증빙 건만 처리할 수 있습니다.");
						return false;
					}
                } else if(items[i].inout_type_cd != "01" && items[i].inout_type_cd != "02" && items[i].inout_type_cd != "21") {
                	alert(items[i].inout_type_name + "전표는 회계전송이 불가능합니다.");
                	return false;	
                }
			}

			var param = {
					inout_doc_no_str : $M.getArrStr(items, {key : 'inout_doc_no'}),
				}
			
			var msg = "회계전송하시겠습니까?";
			
			$M.goNextPageAjaxMsg(msg, "/cust/cust030201/accTrans", $M.toGetParam(param), {method : 'POST'}, 
				function(result) {
					if(result.success) {
						goSearch();
					};
				}
			);
		}
		
		// 21.09.09 (SR : 11682) 카드매출내역탭에서 회계전송가능하도록 수정
		// 회계전송 취소
		function goCancelAccTrans() {
			var row = "";
			var items = AUIGrid.getCheckedRowItemsAll(auiGrid);
			
			if (items.length == 0) {
				alert("체크된 데이터가 없습니다.");
				return false
			}
			
			for (var i = 0; i < items.length; i++) {
				if(items[i].duzon_trans_yn != "Y") {
					alert("회계처리된 건만 취소가 가능합니다.");
					return false;
				}
			}

			var param = {
					inout_doc_no_str : $M.getArrStr(items, {key : 'inout_doc_no'}),
				}
			
			var msg = "회계전송을 취소하시겠습니까?";
			$M.goNextPageAjaxMsg(msg, "/cust/cust030201/cancelAccTrans", $M.toGetParam(param), {method : 'POST'}, 
				function(result) {
					if(result.success) {
						goSearch();
					};
				}
			);
		}
	</script>
</head>
<body style="background : #fff">
<form id="main_form" name="main_form">
	<div class="">
		<!-- contents 전체 영역 -->
		<div class="" style="padding: 0">
			<div class="">
				<!-- 메인 타이틀 -->
				<!-- /메인 타이틀 -->
				<div class="content-wrap" style="margin-top: 5px; padding: 0;">
					<!-- 기본 -->
					<div class="search-wrap">
						<table class="table">
							<colgroup>
								<col width="60px">
								<col width="260px">
								<col width="50px">
								<col width="100px">
								<col width="50px">
								<col width="100px">
								<col width="110px">
								<col width="">
							</colgroup>
							<tbody>
							<tr>
								<th class="rs">처리일자</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width110px">
											<div class="input-group">
												<input type="text" class="form-control rb border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateFormat="yyyy-MM-dd" value="" alt="조회 시작일" onchange="fnUpdateParentStartDt()">
											</div>
										</div>
										<div class="col-auto text-center">~</div>
										<div class="col width120px">
											<div class="input-group">
												<input type="text" class="form-control rb border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateFormat="yyyy-MM-dd"  value="${inputParam.s_current_dt}" alt="조회 완료일" onchange="fnUpdateParentEndDt()">
											</div>
										</div>
										<jsp:include page="/WEB-INF/jsp/common/searchDtType.jsp">
				                     		<jsp:param name="st_field_name" value="s_start_dt"/>
				                     		<jsp:param name="ed_field_name" value="s_end_dt"/>
				                     		<jsp:param name="click_exec_yn" value="Y"/>
				                     		<jsp:param name="exec_func_name" value="fnUpdateParentDtAnGoSearch();"/>
				                     	</jsp:include>
									</div>
								</td>
								<th class="rs">부서</th>
								<td>
									<select class="form-control rb" id="s_org_code" name="s_org_code" required="required" alt="부서" onchange="fnUpdateParentOrgCode()">
										<c:choose>
											<c:when test="${deptList.size() > 1 }">
												<option value="">- 선택 -</option>
											</c:when>
											<c:otherwise></c:otherwise>
										</c:choose>
										<c:forEach var="item" items="${deptList}">
											<option value="${item.org_code }">${item.org_name }</option>
										</c:forEach>
									</select>
								</td>
								<th>상태</th>
								<td>
									<select class="form-control" id="s_imprest_status_cd" name="s_imprest_status_cd" onchange="fnUpdateParentImprestCd()">
										<option value="">- 전체 -</option>
										<c:forEach var="item" items="${codeMap['IMPREST_STATUS']}">
											<option value="${item.code_value }">${item.code_name }</option>
										</c:forEach>
										
										<!-- ASIS.. 확인은 미확인, 발송은 확인.. 등 한단계씩 밀림 -->
										<!-- <option value="0">확인(√)</option>
										<option value="1">발송(△)</option>
										<option value="2">수신(○)</option>
										<option value="3">완결</option>
										<option value="4">전체</option> -->
									</select>
								</td>
								<td class="pl10">
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="checkbox" id="s_except_acnt_confirm" name="s_except_acnt_confirm" value="Y" onchange="fnUpdateParentExcept()">
										<label class="form-check-label" for="s_except_acnt_confirm">완결건 제외</label>
									</div>
								</td>
								<td>
									<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
								</td>
							</tr>
							</tbody>
						</table>
					</div>
					<!-- /기본 -->
					<!-- 그리드 타이틀, 컨트롤 영역 -->
					<div class="title-wrap mt10">
						<h4>조회결과</h4>
						<div class="btn-group">
							<div class="right"><%-- 버튼위치는 pos param 에 따라 나옴 (없으면 기본 상단나옴) T_CODE.CODE_VALUE='BTN_POS' 참고 --%>
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</div>
					</div>
					<!-- /그리드 타이틀, 컨트롤 영역 -->
					<div id="auiGrid" style="margin-top: 5px; height: 555px;  width: 100%"></div>
					<!-- 그리드 서머리, 컨트롤 영역 -->
					<div class="btn-group mt5">
						<div class="left">
							총 <strong class="text-primary" id="total_cnt">0</strong>건
						</div>
					</div>
					<!-- /그리드 서머리, 컨트롤 영역 -->
				</div>
			</div>
		</div>
		<!-- /contents 전체 영역 -->
	</div>
</form>
</body>
</html>