<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 부품통계 > 고객 별 부품구매내역
-- 작성자 : 정윤수
-- 최초 작성일 : 2023-03-07 17:06:41
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var auiGrid;

		$(document).ready(function() {
			createAUIGrid();
		});

		//조회
		function goSearch() {
			var partNoArr = AUIGrid.getAddedColumnFields(auiGrid);
			var custNoArr = AUIGrid.getColumnValues(auiGrid, "cust_no");
			if(partNoArr.length < 1){
				alert('부품을 추가하신 후 조회하시기 바랍니다.');
				return false;
			} else if(custNoArr.length < 1){
				alert('고객을 추가하신 후 조회하시기 바랍니다.');
				return false;
			}
			var param = {
				"s_part_no_str" : partNoArr,
				"s_cust_no_str" : custNoArr,
				"s_start_dt" : $M.getValue("s_start_dt"),
				"s_end_dt" : $M.getValue("s_end_dt"),
                "s_masking_yn" : $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N"
			};
			$M.goNextPageAjax(this_page + '/search', $M.toGetParam(param), {method : 'post'},
					function(result){
						if(result.success) {
							AUIGrid.setGridData(auiGrid, result.list);
						};
					}
			);
		}
		
		// 고객추가
		function goAddCust() {
			var params = {
				"parent_js_name" : "fnSetCustInfo",
				"s_masking_yn" : $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N"
			};
			var popupOption = "";
			$M.goNextPage('/part/part0608p01', $M.toGetParam(params), {popupStatus : popupOption});
		}

		//고객조회 팝업에서 선택한 고객 추가
		function fnSetCustInfo(data) {
			var row = new Object();
			if(data != null) {
				for(i=0; i<data.length; i++) {
					if(AUIGrid.getItemsByValue(auiGrid, "cust_no", data[i].cust_no).length == 0) {
						row.cust_no = typeof data[i].cust_no == "undefined" ? "" : data[i].cust_no;
						row.origin_hp_no = typeof data[i].hp_no == "undefined" ? "" : data[i].hp_no;
						row.origin_cust_name = typeof data[i].cust_name == "undefined" ? "" : data[i].cust_name;
						if($M.getValue("s_masking_yn") == "Y"){
							row.cust_hp_no = typeof data[i].hp_no == "undefined" ? "" : data[i].masking_hp_no;
							row.cust_name = typeof data[i].cust_name == "undefined" ? "" : data[i].masking_cust_name;
						} else {
							row.cust_hp_no = typeof data[i].hp_no == "undefined" ? "" : data[i].hp_no;
							row.cust_name = typeof data[i].cust_name == "undefined" ? "" : data[i].cust_name;
						}
						AUIGrid.addRow(auiGrid, row, 'last');
					}
				}
			}
		}
		
		// 부품추가
		function goAddPartPopup() {
			openSearchPartPanel("fnSetPart", "Y");
		}

		// 선택한 부품 컬럼에 추가
		function fnSetPart(rowArr) {
			var partNoArr = AUIGrid.getAddedColumnFields(auiGrid);
			for (var i = 0; i < rowArr.length; i++ ) {
				var item = rowArr[i];
				// var partNo = "'" + item.part_no.toLowerCase() + "'";
				var partNo = item.part_no.toLowerCase();

				if(partNoArr.length >= 10){
					return "더 이상 부품을 추가할 수 없습니다";
				}
				if(partNoArr.indexOf(partNo) != -1){
					return "부품번호를 다시 확인하세요.\n" + item.part_no + " 이미 입력한 부품번호입니다.";
				}
				var columnObj = {
					headerText : item.part_name,
					width : "9%",
					children : [
						{
							headerText : item.part_no,
							dataField : item.part_no.toLowerCase(), // 조회 시 소문자로 반환되어서 변경
							width : "9%",
							style : "aui-center aui-popup",
							dataType : "numeric",
							formatString : "#,###",
							labelFunction : function(rowIndex, columnIndex, value){
								if (value == "0") {
									return "";
								} else {
									return $M.setComma(value);
								}
							},
							headerRenderer : { // 헤더 렌더러
								type : "ButtonHeaderRenderer",
								position : "right",
								text : "×",
								onClick : function(event) {  // 클릭 핸들러
									var colindex = AUIGrid.getColumnIndexByDataField(auiGrid, event.dataField);
									// 클릭한 열 삭제
									AUIGrid.removeColumn(auiGrid, colindex);
									for(var i = 0; i < partNoArr.length; i++){
										if (partNoArr[i] == item.part_no) {
											partNoArr.splice(i, 1);
											i--;
										}
									}
								},
							},
						}
					]
				};
				AUIGrid.addColumn(auiGrid, columnObj, 'last');
			}
		}


		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				// rowNumber
				showRowNumColumn: true,
				// 체크박스 출력 여부
				showRowCheckColumn : true,
				// 전체선택 체크박스 표시 여부
				showRowAllCheckBox : true,
				softRemoveRowMode : false,
				nullsLastOnSorting : true, // 정렬 시 null이나 ""값 마지막으로 보냄
				sortableByFormatValue : true, // 정렬 시 데이터 기반이 아닌 그리드에 출력된 값을 기반으로 정렬을 실행
			};
			var columnLayout = [
				{
					headerText : "고객명",
					dataField : "cust_name",
					width : "100",
					minWidth : "100",
					style : "aui-center"
				},
				{
					headerText : "핸드폰번호",
					dataField : "cust_hp_no",
					width : "110",
					minWidth : "130",
					style : "aui-center",
				},
				{
					dataField : "cust_no",
					visible : false
				},
				{
					dataField : "origin_cust_name",
					visible : false
				},
				{
					dataField : "origin_hp_no",
					visible : false
				},
				];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if (event.dataField.toUpperCase() == event.headerText && event.value != "") {
					var param = {
						"part_no" : event.dataField.toUpperCase(),
						"tap_no" : "3",
					};
					var popupOption = "";
					$M.goNextPage('/part/part0101p01', $M.toGetParam(param),  {popupStatus : popupOption});
				}
			});

		}
		
		// 체크 후 삭제
		function fnRemove(){
			var checkedItems = AUIGrid.getCheckedRowItemsAll(auiGrid);
			if (checkedItems.length == 0) {
				alert("체크된 고객이 없습니다.");
				return false;
			} else {
				for (var i = 0; i < checkedItems.length; ++i) {
					AUIGrid.removeRowByRowId(auiGrid, checkedItems[i]._$uid);
				}
			}
		}

		// 문자발송
		function fnSendSms() {

			var items = AUIGrid.getCheckedRowItemsAll(auiGrid);
			if (items.length == 0) {
				alert("체크된 데이터가 없습니다.");
				return false
			}

			var params = {
				sms_send_type_cd: "2",
				req_sendtarger_yn: "Y"
			};
			openSendSmsPanel($M.toGetParam(params));
		}


		function reqSendTargetList() {

			var items = AUIGrid.getCheckedRowItemsAll(auiGrid);

			var parentTargetList = [];

			for (var i = 0; i < items.length; i++) {
				var obj = new Object();
				obj['phone_no'] = items[i].origin_hp_no;
				obj['receiver_name'] = items[i].origin_cust_name;
				obj['ref_key'] = items[i].cust_no;
				parentTargetList.push(obj);
			}

			return parentTargetList;
		}

		//엑셀다운로드
		function fnExcelDownload() {
			fnExportExcel(auiGrid, "고객 별 부품구매내역");
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
								<col width="70px">
								<col width="260px">
								<col width="">
							</colgroup>
							<tbody>
							<tr>
								<th>조회기간</th>
								<td>
									<div class="form-row inline-pd">
										<div class="col-5" >
											<div class="input-group">
												<input type="text" class="form-control border-right-0  calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" alt="시작일" value="${searchDtMap.s_start_dt}">
											</div>
										</div>
										<div class="col-auto">~</div>
										<div class="col-5" >
											<div class="input-group">
												<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" alt="종료일" value="${searchDtMap.s_end_dt}">
											</div>
										</div>
										<jsp:include page="/WEB-INF/jsp/common/searchDtType.jsp">
											<jsp:param name="st_field_name" value="s_start_dt"/>
											<jsp:param name="ed_field_name" value="s_end_dt"/>
										</jsp:include>
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
						<h4>조회결과</h4>
						<div class="btn-group">
							<div class="right">
                                <c:if test="${page.add.POS_UNMASKING eq 'Y'}">
                                    <div class="form-check form-check-inline">
                                        <input  class="form-check-input"  type="checkbox" id="s_masking_yn" name="s_masking_yn"<c:if test="${page.masking_default_yn eq 'Y'}" > checked</c:if> value="Y" >
                                        <label  class="form-check-input"  for="s_masking_yn" >마스킹 적용</label>
                                    </div>
                                </c:if>
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>

							</div>
						</div>
					</div>
					<!-- /그리드 타이틀, 컨트롤 영역 -->

					<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>

				</div>

			</div>
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
		</div>
		<!-- /contents 전체 영역 -->
	</div>
</form>
</body>
</html>