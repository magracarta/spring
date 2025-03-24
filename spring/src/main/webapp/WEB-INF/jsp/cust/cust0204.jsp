<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 부품판매 > 센터별미수현황 > null > null
-- 작성자 : 담당자 이름을 넣어주세요.
-- 최초 작성일 : 2019-12-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		//분류
		var misuTypeGbList = [{"code_value":"G", "code_name" : "일반"}, {"code_value" :"B", "code_name" :"악성"}];
		// 화면에 보여지는 그리드 데이터 목록
		var gridAllList;
	    var auiGrid;
		$(document).ready(function() {
			// AUIGrid 생성
			createAUIGrid();
			goSearch();
		});

		// 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_cust_name", "s_misu_mem_name"];
			$.each(field, function () {
				if (fieldObj.name == this) {
					goSearch();
				}
			});
		}

		// 검색
		function goSearch() {
			if ($M.validation(document.main_form) == false) {
				return;
			}

			var param = {
				"s_cust_name": $M.getValue("s_cust_name"),
				"s_misu_mem_name": $M.getValue("s_misu_mem_name"),
				"s_center_org_code": $M.getValue("s_center_org_code"),
				"s_misu_type": $M.getValue("s_misu_type"),
				"s_misu_type_gb": $M.getValue("s_misu_type_gb"),
				"s_current_not_misu_yn": $M.getValue("s_current_not_misu_yn"),
				"s_suspension_sales_yn": $M.getValue("s_suspension_sales_yn"),
				"s_not_agency_include_yn": $M.getValue("s_not_agency_include_yn"),
			};

			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: 'get'},
					function (result) {
						if (result.success) {
							AUIGrid.setGridData(auiGrid, result.list);
							gridAllList = AUIGrid.getGridData(auiGrid);
						}
					}
			);
		}

		// 엑셀다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, "센터별미수현황");
		}

		// 그리드 빈값 체크
		function fnCheckGridEmpty() {
			return AUIGrid.validation(auiGrid);
		}

		// 저장
		function goSave() {
			if (fnChangeGridDataCnt(auiGrid) == 0) {
				alert("변경된 데이터가 없습니다.");
				return false;
			}

			var editedRowItems = AUIGrid.getEditedRowItems(auiGrid);
			for(var i=0; i<editedRowItems.length; i++) {
				if(editedRowItems[i].misu_type_gb == "") {
					alert("구분은 필수 값 입니다.");
					return;
				}

				if(editedRowItems[i].misu_proc_meet_dt == "") {
					alert("미수처리 접촉일은 필수 값 입니다.");
					return;
				}
			}

			var frm = fnChangeGridDataToForm(auiGrid);
			$M.goNextPageAjaxSave(this_page + "/save", frm, {method: 'POST'},
					function (result) {
						if (result.success) {
							goSearch();
						}
					}
			);
		}

		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				wrapSelectionMove : false,
				showRowNumColumn : false,
				editable : true,
				headerHeight : 40,
				enableCellMerge : true,
				cellMergeRowSpan:  true,
				cellMergePolicy : "valueWithNull",
				showFooter : true,
				footerPosition : "top",
				// 푸터 출력 행 개수 설정
				footerRowCount : "1",
				// 기본 푸터 높이
				footerHeight : 24
			};

			var columnLayout = [
				{
					headerText : "센터",
					dataField : "center_org_name",
					width : "70",
					minWidth : "60",
					style : "aui-center",
					editable : false,
					cellMerge : true, // 구분1 셀 세로 병합 실행
					mergeRef : "cust_no", // 대분류(gubun0 필드) 셀머지의 값을 비교해서 실행함. (mergePolicy : "restrict" 설정 필수)
					mergePolicy : "restrict"
				},
				{
					headerText : "고객명",
					dataField : "cust_name",
					editable : false,
					width : "100",
					minWidth : "45",
					cellMerge : true, // 구분1 셀 세로 병합 실행
					mergeRef : "cust_no", // 대분류(gubun0 필드) 셀머지의 값을 비교해서 실행함. (mergePolicy : "restrict" 설정 필수)
					mergePolicy : "restrict",
					style : "aui-center aui-popup",
				},
				{
					dataField : "cust_no",
					headerText : "고객번호",
					visible: false,
					cellMerge : true
				},
				{
					headerText : "구분",
					dataField : "misu_type_gb_name",
					width : "40",
					minWidth : "30",
					required : true,
					style : "aui-center",
					cellMerge : true, // 구분1 셀 세로 병합 실행
					mergeRef : "cust_no", // 대분류(gubun0 필드) 셀머지의 값을 비교해서 실행함. (mergePolicy : "restrict" 설정 필수)
					mergePolicy : "restrict",
					editable : false,
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if(item.misu_type_gb_name == "악성") {
							return "aui-color-red";
						}
					}
				},
				{
					headerText : "구분",
					dataField : "misu_type_gb",
					width : "100",
					minWidth : "45",
					required : true,
					style : "aui-center aui-editable",
					cellMerge : true, // 구분1 셀 세로 병합 실행
					mergeRef : "cust_no", // 대분류(gubun0 필드) 셀머지의 값을 비교해서 실행함. (mergePolicy : "restrict" 설정 필수)
					mergePolicy : "restrict",
					visible : false
				},
				{
					headerText : "분류",
					dataField : "misu_type",
					visible : false
				},
				{
					headerText : "분류",
					dataField : "misu_type_name",
					width : "70",
					minWidth : "60",
					style : "aui-center",
					editable : false
				},
				{
					headerText : "${inputParam.s_b2_mon}" + "월",
					dataField : "b2_misu_amt",
					width : "80",
					minWidth : "70",
					editable : false,
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0",
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						return value == "0" ? "" : $M.setComma(value);
					}
				},
				{
					headerText : "${inputParam.s_b1_mon}"  + "월",
					dataField : "b1_misu_amt",
					width : "80",
					minWidth : "70",
					editable : false,
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0",
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						return value == "0" ? "" : $M.setComma(value);
					}
				},
				{
					headerText : "당월",
					dataField : "b0_misu_amt",
					width : "80",
					minWidth : "70",
					editable : false,
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0",
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						return value == "0" ? "" : $M.setComma(value);
					}
				},
				{
					headerText : "분류별<br>총미수금액",
					dataField : "curr_misu_gubun_amt",
					width : "80",
					minWidth : "70",
					editable : false,
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0",
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						return value == "0" ? "" : $M.setComma(value);
					}
				},
				{
					headerText : "총미수금액",
					dataField : "curr_misu_amt",
					width : "80",
					minWidth : "70",
					style : "aui-right",
					editable : false,
					cellMerge : true, // 구분1 셀 세로 병합 실행
					mergeRef : "cust_no", // 대분류(gubun0 필드) 셀머지의 값을 비교해서 실행함. (mergePolicy : "restrict" 설정 필수)
					mergePolicy : "restrict",
					dataType : "numeric",
					formatString : "#,##0",
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						return value == "0" ? "" : $M.setComma(value);
					}
				},
				{
					headerText : "미수담당자",
					dataField : "misu_mem_name",
					width : "80",
					minWidth : "70",
					style : "aui-center",
					editable : false,
					cellMerge : true, // 구분1 셀 세로 병합 실행
					mergeRef : "cust_no", // 대분류(gubun0 필드) 셀머지의 값을 비교해서 실행함. (mergePolicy : "restrict" 설정 필수)
					mergePolicy : "restrict"
				},
				{
					headerText : "미수처리<br>접촉일",
					dataField : "misu_proc_meet_dt",
					width : "70",
					minWidth : "60",
					dataType : "date",
					style : "aui-center aui-editable",
					dataInputString : "yyyymmdd",
					formatString : "yy-mm-dd",
					style : "aui-center",
					required : true,
					cellMerge : true, // 구분1 셀 세로 병합 실행
					mergeRef : "cust_no", // 대분류(gubun0 필드) 셀머지의 값을 비교해서 실행함. (mergePolicy : "restrict" 설정 필수)
					mergePolicy : "restrict",
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
					editable : true
				},
				{
					headerText : "마지막<br>거래일",
					dataField : "cust_last_deal_dt",
					editable : false,
					width : "70",
					minWidth : "60",
					style : "aui-center",
					dataType : "date",
					formatString : "yy-mm-dd",
					editable : false,
					cellMerge : true, // 구분1 셀 세로 병합 실행
					mergeRef : "cust_no", // 대분류(gubun0 필드) 셀머지의 값을 비교해서 실행함. (mergePolicy : "restrict" 설정 필수)
					mergePolicy : "restrict"
				},
				{
					headerText : "거래원장메모_미수사유",
					dataField : "last_memo",
					style : "aui-left",
					editable : false,
					cellMerge : true, // 구분1 셀 세로 병합 실행
					mergeRef : "cust_no", // 대분류(gubun0 필드) 셀머지의 값을 비교해서 실행함. (mergePolicy : "restrict" 설정 필수)
					mergePolicy : "restrict",
					width : "320",
					minWidth : "310"
				},
				{
					headerText : "입금예정일",
					dataField : "deposit_plan_dt",
					width : "70",
					minWidth : "60",
					style : "aui-center",
					dataType : "date",
		            formatString : "yy-mm-dd",
					editable : false,
					cellMerge : true, // 구분1 셀 세로 병합 실행
					mergeRef : "cust_no", // 대분류(gubun0 필드) 셀머지의 값을 비교해서 실행함. (mergePolicy : "restrict" 설정 필수)
					mergePolicy : "restrict"
				}
			];
			// 푸터레이아웃
			var footerLayout = [
				{
					labelText : "정비 미수 총액",
					positionField : "center_org_name",
					colSpan : 11,
					style : "aui-center aui-footer"
				},
				{
					dataField : "curr_misu_amt",
					positionField : "curr_misu_amt",
					operation: "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
					expFunction : function() {
						var totalMisuAmt = 0;
						var gridData = AUIGrid.getGridData(auiGrid);
						for(var i=0; i < gridData.length; i++) {
							if(gridData[i].misu_type == "ED_PART_MISU_AMT") {
								var currMisuAmt = $M.toNum(gridData[i].curr_misu_amt);
								if(currMisuAmt > 0) {
									totalMisuAmt += currMisuAmt;
								}
							}
						}

						return totalMisuAmt;
					}
				},
				{
					positionField : "last_memo",
					colSpan : 2,
					style : "aui-right aui-footer",
				}
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 푸터 객체 세팅
			AUIGrid.setFooter(auiGrid, footerLayout);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();

			//셀병합된 드랍다운리스트 , 달력정보는 한개를 바꿀시 다같이 변경하도록 처리 ( 구분 , 미수처리접촉일 )
			AUIGrid.bind(auiGrid, "cellEditEnd", function(event) {
				var item_cust_no = event.item.cust_no;
				var evantVal = event.value;

				switch (event.dataField) {
					case "misu_proc_meet_dt": //미수처리접촉일
						//동일한 고객번호는 모두 업데이트 하기
						for (var i = 0; i < gridAllList.length; i++) {
							if ((gridAllList[i].cust_no == item_cust_no)) {
								AUIGrid.updateRow(auiGrid, {"misu_proc_meet_dt": evantVal}, i, false);
							}
						}
						return;
					case "misu_type_gb" : // 구분
						//동일한 고객번호는 모두 업데이트 하기
						for (var i = 0; i < gridAllList.length; i++) {
							if ((gridAllList[i].cust_no == item_cust_no)) {
								AUIGrid.updateRow(auiGrid, {"misu_type_gb": evantVal}, i, false);
							}
						}
						break;
					default:
						return;
				}
			});

			// 발주내역 클릭시 -> 발주서상세 팝업 호출
			AUIGrid.bind(auiGrid, "cellClick", function (event) {
				if (event.dataField == "cust_name") {
					var param = {
						"s_cust_no": event.item.cust_no
					};
					openDealLedgerPanel($M.toGetParam(param));

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
					<!-- 기본 -->
					<div class="search-wrap">
						<table class="table">
							<colgroup>
								<col width="50px">
								<col width="90px">
								<col width="55px">
								<col width="90px">
								<col width="40px">
								<col width="90px">
								<col width="45px">
								<col width="100px">
								<col width="40px">
								<col width="90px">
								<col width="340px">
								<col width="">
							</colgroup>
							<tbody>
							<tr>
								<th>고객명</th>
								<td>
									<div class="icon-btn-cancel-wrap">
										<input type="text" class="form-control" id="s_cust_name" name="s_cust_name">
										<button type="button" class="icon-btn-cancel"></button>
									</div>
								</td>
								<th>담당자</th>
								<td>
									<div class="icon-btn-cancel-wrap">
										<input type="text" class="form-control" id="s_misu_mem_name" name="s_misu_mem_name">
										<button type="button" class="icon-btn-cancel"></button>
									</div>
								</td>
								<th>센터</th>
								<td>
									<select class="form-control" name="s_center_org_code" id="s_center_org_code" alt="센터">
										<option value="">- 전체 -</option>
										<c:forEach var="item" items="${orgCenterList}">
											<option value="${item.org_code}" <c:if test="${item.org_code eq SecureUser.org_code }">selected</c:if>>${item.org_name}</option>
										</c:forEach>
									</select>
								</td>
								<th>분류</th>
								<td>
									<select class="form-control" id="s_misu_type" name="s_misu_type">
										<option value="">- 전체 -</option>
										<option value="REPAIR_MISU_AMT">정비</option>
										<option value="RENTAL_MISU_AMT">렌탈</option>
										<option value="PART_MISU_AMT">부품</option>
									</select>
								</td>
								<th>구분</th>
								<td class="mr5">
									<select class="form-control" id="s_misu_type_gb" name="s_misu_type_gb">
										<option value="">- 전체 -</option>
										<option value="G">일반</option>
										<option value="B">악성</option>
									</select>
								</td>
								<td class="pl10">
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="checkbox" id="s_current_not_misu_yn" name="s_current_not_misu_yn" checked="checked">
										<label class="form-check-label" for="s_current_not_misu_yn">현 미수업체만</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="checkbox" id="s_suspension_sales_yn" name="s_suspension_sales_yn">
										<label class="form-check-label" for="s_suspension_sales_yn">매출정지업체만</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="checkbox" id="s_not_agency_include_yn" name="s_not_agency_include_yn">
										<%-- [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체 --%>
										<%--<label class="form-check-label" for="s_not_agency_include_yn">대리점고객제외</label>--%>
										<label class="form-check-label" for="s_not_agency_include_yn">위탁판매점고객제외</label>
									</div>
								</td>
								<td class="">
									<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
								</td>
							</tr>
							</tbody>
						</table>
					</div>
					<!-- /기본 -->
					<!-- 그리드 타이틀, 컨트롤 영역 -->
					<div class="title-wrap mt10">
						<h4>미수내역</h4>
						<div class="btn-group">
							<div class="right">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</div>
					</div>
					<!-- /그리드 타이틀, 컨트롤 영역 -->
					<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
					<!-- 그리드 서머리, 컨트롤 영역 -->
					<div class="btn-group mt5">
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						</div>
					</div>
					<!-- /그리드 서머리, 컨트롤 영역 -->
				</div>
			</div>
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
		</div>
		<!-- /contents 전체 영역 -->
	</div>
</form>
</body>
</html>
