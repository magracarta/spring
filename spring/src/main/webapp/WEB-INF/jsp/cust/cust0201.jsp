<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 부품판매 > 수주현황/등록 > null > null
-- 작성자 : 박예진
-- 최초 작성일 : 2019-12-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">


		var dataFieldName = []; // 펼침 항목(create할때 넣음)

		$(document).ready(function() {
			createAUIGrid();
			goSearch();
// 			fnInit();
		});

// 		function fnInit() {
// 			var now = "${inputParam.s_current_dt}";
// 			$M.setValue("s_start_dt", $M.addMonths($M.toDate(now), -1));

// 		}

		// 펼침
		function fnChangeColumn(event) {
			var data = AUIGrid.getGridData(auiGrid);
			var target = event.target || event.srcElement;
			if(!target)	return;

			var dataField = target.value;
			var checked = target.checked;

			for (var i = 0; i < dataFieldName.length; ++i) {
				var dataField = dataFieldName[i];

				if(checked) {
					AUIGrid.showColumnByDataField(auiGrid, dataField);
				} else {
					AUIGrid.hideColumnByDataField(auiGrid, dataField);
				}
			}
		}

		//조회
		function goSearch() {
			var param = {
					"s_sort_key" : "sale_dt",
					"s_sort_method" : "desc",
					"s_cust_name" : $M.getValue("s_cust_name"),
					"s_part_sale_type_ca" : $M.getValue("s_part_sale_type_ca"),
					"s_part_sale_status_cd" : $M.getValue("s_part_sale_status_cd"),
					"s_center_org_code" : $M.getValue("s_center_org_code"),
					"s_preorder_yn" : $M.getValue("s_preorder_yn"),
					"s_start_dt" : $M.getValue("s_start_dt"),
					"s_end_dt" : $M.getValue("s_end_dt")
			};
			_fnAddSearchDt(param, 's_start_dt', 's_end_dt');
			$M.goNextPageAjax(this_page + '/search', $M.toGetParam(param), {method : 'get'},
					function(result) {
						if(result.success) {
							AUIGrid.setGridData(auiGrid, result.list);
							console.log(result.list);
							$("#total_cnt").html(result.total_cnt);
						};
					}
				);
		}

		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn: true,
				treeColumnIndex : 6,
				headerHeight : 40,
				// 고정칼럼 카운트 지정
				// fixedColumnCount : 7,
				/* rowStyleFunction : function(rowIndex, item) {
					 if(item.part_sale_status_cd == "9") {
						 // 마감일 때
						 return "aui-row-part-sale-end";
					 } else if(item.part_sale_status_cd == "2") {
					  	 // 확정일 때
						 return "aui-row-part-sale-complete";
					 }
					 return "";
				} */
			};
			var columnLayout = [
				{
					headerText : "수주일",
					dataField : "sale_dt",
					dataType : "date",
					formatString : "yy-mm-dd",
					width : "75",
					minWidth : "75",
					style : "aui-center",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var saleDt = AUIGrid.formatDate(value, "yy-mm-dd");
						if(item["seq_depth"] != "1") {
							saleDt = "";
						}
				    	return saleDt;
					}
				},
				{
					headerText : "수주번호",
					dataField : "part_sale_no",
					width : "70",
					minWidth : "70",
					style : "aui-center aui-popup",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var partSaleNo = value;
						if(item["seq_depth"] != "1") {
							partSaleNo = "";
						}
				    	return partSaleNo.substring(4);
					}
				},
				{
					headerText : "수주<br\>종류",
					dataField : "preorder_yn",
					width : "50",
					minWidth : "50",
					style : "aui-center",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var preorderYn = "";
						if(item['preorder_yn'] == 'Y') {
							preorderYn = "선주문";
						} else if(item['preorder_yn'] == 'N') {
							preorderYn = "일반";
						}
				    	return preorderYn;
					}
				},
				{
					headerText : "수주<br\>구분",
					dataField : "part_sale_type_ca",
					headerStyle : "aui-fold",
					width : "50",
					minWidth : "50",
					style : "aui-center",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var saleType = "";
						if(item['part_sale_type_ca'] == 'C') {
							saleType = "고객";
						} else if(item['part_sale_type_ca'] == 'A') {
							// [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
							// saleType = "대리점";
							saleType = "위탁판매점";
						}
				    	return saleType;
					}
				},
				{
					headerText : "고객명",
					dataField : "cust_name",
					width : "120",
					minWidth : "110",
					style : "aui-center",
				},
				{
					headerText : "배송희망일",
					dataField : "delivery_plan_dt",
					headerStyle : "aui-fold",
					dataType : "date",
					formatString : "yy-mm-dd",
					width : "75",
					minWidth : "75",
					style : "aui-center",
				},
				{
					headerText : "품번",
					dataField : "part_no",
					width : "170",
					minWidth : "170",
					style : "aui-left"
				},
				{
					headerText : "품명",
					dataField : "part_name",
					width : "220",
					minWidth : "220",
					style : "aui-left"
				},
				{
					headerText : "수량",
					dataField : "total_qty",
					dataType : "numeric",
					formatString : "#,##0",
					width : "50",
					minWidth : "50",
					style : "aui-center"
				},
				{
					headerText : "현재고",
					dataField : "current_qty",
					headerStyle : "aui-fold",
					dataType : "numeric",
					formatString : "#,##0",
					width : "60",
					minWidth : "60",
					visible : false
				},
				{
					headerText : "발송가능<br\>여부",
					dataField : "send_yn",
					headerStyle : "aui-fold",
					width : "65",
					minWidth : "65",
					style : "aui-center",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var sendYn = "";
						if(item["send_yn"] == 'Y' && item["part_sale_status_cd"] != "9") {
							sendYn = "가능";
						} else if(item["send_yn"] == 'N' && item["part_sale_status_cd"] != "9") {
							sendYn = "불가";
						} else {
							sendYn = "";
						}
				    	return sendYn;
					},
// 					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
// 						if(item["send_yn"] == "Y" && item["aui_status_cd"] == "P") {
// 							return "aui-part-sale-row-style";
// 						} else if(item["send_yn"] == "Y" && item["aui_status_cd"] == "C") {
// 							return "aui-part-sale-complete";
// 						} else if(item["send_yn"] == "Y" && item["aui_status_cd"] == "D") {
// 							return "aui-part-sale-send-default";
// 						}
// 						return "aui-status-default";
// 					},
				},
				{
					headerText : "알람",
					dataField : "paper_send_yn",
					headerStyle : "aui-fold",
					width : "50",
					minWidth : "50",
					style : "aui-center",
					renderer : { // HTML 템플릿 렌더러 사용
						type : "TemplateRenderer"
					},
					// dataField 로 정의된 필드 값이 HTML 이라면 labelFunction 으로 처리할 필요 없음.
					labelFunction : function (rowIndex, columnIndex, value, headerText, item ) { // HTML 템플릿 작성
						if($M.nvl(value, "") == "Y"){
							template = '<div><i class="material-iconsdone text-default"></i></div>';
						} else {
							template = "";
						}
						return template;
					}
				},
				{
					headerText : "적요",
					dataField : "desc_text",
					width : "230",
					minWidth : "200",
					style : "aui-left"
				},
				{
					headerText : "금액",
					dataField : "total_amt",
					headerStyle : "aui-fold",
					dataType : "numeric",
					onlyNumeric : true,
					formatString : "#,##0",
					width : "85",
					minWidth : "75",
					style : "aui-right",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var totalAmt = AUIGrid.formatNumber(value, "#,##0");
						if(item["seq_depth"] != "1") {
							totalAmt = "";
						}
				    	return totalAmt;
					}
				},
				{
					headerText : "부가세포함",
					dataField : "sale_amt",
					dataType : "numeric",
					onlyNumeric : true,
					formatString : "#,##0",
					width : "85",
					minWidth : "75",
					style : "aui-right",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var saleAmt = AUIGrid.formatNumber(value, "#,##0");
						if(item["seq_depth"] != "1") {
							saleAmt = "";
						}
				    	return saleAmt;
					}
				},
				{
					headerText : "입금액",
					dataField : "acct_amt",
					headerStyle : "aui-fold",
					dataType : "numeric",
					onlyNumeric : true,
					formatString : "#,##0",
					width : "85",
					minWidth : "75",
					style : "aui-right",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var saleAmt = AUIGrid.formatNumber(value, "#,##0");
						if(item["seq_depth"] != "1") {
							saleAmt = "";
						}
				    	return saleAmt;
					}
				},
				{
					headerText : "입금<br\>여부",
					dataField : "acct_yn",
					headerStyle : "aui-fold",
					width : "50",
					minWidth : "50",
					style : "aui-center",
// 					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
// 						var acctYn = "";
// 						if(item["acct_yn"] == 'Y' && item["seq_depth"] == "1") {
// 							acctYn = "완료";
// 						} else if(item["acct_yn"] == 'N' && item["seq_depth"] == "1") {
// 							acctYn = "미완료";
// 						}
// 				    	return acctYn;
// 					}
				},
				{
					headerText : "입금일",
					dataField : "acct_dt",
					headerStyle : "aui-fold",
					dataType : "date",
					formatString : "yy-mm-dd",
					width : "75",
					minWidth : "75",
					style : "aui-center"
				},
				{
					headerText : "접수일시",
					dataField : "reg_date",
					headerStyle : "aui-fold",
					dataType : "date",
// 					formatString : "yyyy-MM-dd HH:mm:ss",
					width : "140",
					minWidth : "140",
					style : "aui-center",
				},
				{
					headerText : "마감일시",
					dataField : "end_date",
					headerStyle : "aui-fold",
					dataType : "date",
// 					formatString : "yyyy-MM-dd HH:mm:ss",
					width : "140",
					minWidth : "140",
					style : "aui-center",
				},
				{
					headerText : "진행상태",
					dataField : "part_sale_status_cd",
					width : "60",
					minWidth : "60",
					style : "aui-center",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var status = "";
						if(item["part_sale_status_cd"] == "9" && item["seq_depth"] == "1") {
							status = "마감";
						} else if(item["part_sale_status_cd"] == "2" && item["seq_depth"] == "1") {
							status = "확정";
						} else if(item["part_sale_status_cd"] == "0" && item["seq_depth"] == "1") {
							status = "작성중";
						} else {
							status = "";
						}
				    	return status;
					}
				},
				{
					headerText : "배송상태",
					dataField : "cust_ord_status_name",
					width : "110",
					minWidth : "110",
					style : "aui-center",
				},
				{
					headerText : "확정일",
					dataField : "fix_dt",
					headerStyle : "aui-fold",
					dataType : "date",
					formatString : "yy-mm-dd",
					width : "75",
					minWidth : "75",
					style : "aui-center"
				},
				{
					headerText : "센터",
					dataField : "acct_org_name",
					width : "70",
					minWidth : "70",
					style : "aui-center"
				},
				{
					headerText : "작성자",
					dataField : "reg_mem_name",
					width : "80",
					minWidth : "80",
					style : "aui-center"
				},
				{
					headerText : "고객번호",
					dataField : "cust_no",
					visible : false
				},
				{
					headerText : "seq_depth",
					dataField : "seq_depth",
					visible : false
				},
				{
					headerText : "센터코드",
					dataField : "acct_org_code",
					visible : false
				},
				{
					dataField : "aui_status_cd",
					visible : false
				},
				{
					dataField : "sale_part_sale_no",
					visible : false
				},
				{
					dataField : "part_return_no",
					visible : false
				},
				{
					dataField : "temp_yn",
					visible : false
				}
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();
			// 품번 클릭시 -> 수주상세 팝업 호출
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(event.dataField == "part_sale_no") {
					var test = AUIGrid.getParentItemByRowId(auiGrid, event.item.part_sale_status_cd);
					var param = {
							"part_sale_no" : event.item["part_sale_no"],
							"sale_part_sale_no" : event.item["sale_part_sale_no"], // 반품 수주전표번호
							"part_return_no" : event.item["part_return_no"], // 반품번호
							"temp_yn" : event.item["temp_yn"], // 임시여부
							"login_mem_no" : "${SecureUser.mem_no}"
						};
					var popupOption = "";
					$M.goNextPage('/cust/cust0201p01', $M.toGetParam(param), {popupStatus : popupOption});
				} else if(event.dataField == "send_yn") {
					if(event.item["send_yn"] == "Y") {
						var param = {
								"part_no" : event.item["part_no"]
							};
						// 발송가능여부 셀 클릭 시 부품재고상세 팝업 호출
						var popupOption = "";
						$M.goNextPage('/part/part0101p01', $M.toGetParam(param),  {popupStatus : popupOption});
					}
				}
			});


			// 펼치기 전에 접힐 컬럼 목록
			var auiColList = AUIGrid.getColumnInfoList(auiGrid);
			for (var i = 0; i <auiColList.length; ++i) {
				if (auiColList[i].headerStyle != null && auiColList[i].headerStyle == "aui-fold") {
					dataFieldName.push(auiColList[i].dataField);
				}
			}

			for (var i = 0; i < dataFieldName.length; ++i) {
				var dataField = dataFieldName[i];
				AUIGrid.hideColumnByDataField(auiGrid, dataField);
			}

		}

		function fnDownloadExcel() {
			  // 엑셀 내보내기 속성
			  var exportProps = {
			  };
			  fnExportExcel(auiGrid, "수주현황", exportProps);
		}

		// 엔터키 이벤트
		function enter(fieldObj) {
			var name = fieldObj.name;
			if (name == "s_cust_name") {
				goSearch();
			}
		}

		// 페이지 이동
		function goNew() {
			var popupOption = "";
			var param = {
					"s_popup_yn" : "Y"
			}
			$M.goNextPage('/cust/cust020101', $M.toGetParam(param),  {popupStatus : popupOption});
		}

	</script>
</head>
<body>
<form id="main_form" name="main_form">
 <input type="hidden" name="org_gubun_cd" id="org_gubun_cd" value="${SecureUser.org_type}">
 <input type="hidden" name="login_org_code" id="login_org_code" value="${SecureUser.org_code}">
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
								<col width="55px">
								<col width="260px">
								<col width="50px">
								<col width="120px">
								<col width="80px">
								<col width="100px">
								<col width="80px">
								<col width="90px">
								<col width="80px">
								<col width="90px">
								<col width="50px">
								<col width="100px">
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<th>수주일</th>
									<td>
										<div class="form-row inline-pd">
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" alt="요청시작일" value="${searchDtMap.s_start_dt}">
												</div>
											</div>
											<div class="col-auto text-center">~</div>
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" alt="요청종료일" value="${searchDtMap.s_end_dt}">
												</div>
											</div>
											<jsp:include page="/WEB-INF/jsp/common/searchDtType.jsp">
				                     		<jsp:param name="st_field_name" value="s_start_dt"/>
				                     		<jsp:param name="ed_field_name" value="s_end_dt"/>
				                     		<jsp:param name="click_exec_yn" value="Y"/>
				                     		<jsp:param name="exec_func_name" value="goSearch();"/>
				                     		</jsp:include>
										</div>
									</td>
									<th>고객명</th>
									<td>
									<div class="icon-btn-cancel-wrap">
<%--									<c:if test="${SecureUser.org_type eq 'AGENCY'}">--%>
									<c:if test="${page.fnc.F00029_001 eq 'Y'}">
										<input type="text" class="form-control" id="s_cust_name" name="s_cust_name" value="${cust_name}" readonly="readonly">
									</c:if>
<%--									<c:if test="${SecureUser.org_type ne 'AGENCY'}">--%>
									<c:if test="${page.fnc.F00029_001 ne 'Y'}">
										<input type="text" class="form-control" id="s_cust_name" name="s_cust_name">
									</c:if>
										</div>
									</td>
									<th>수주구분</th>
									<td>
										<select class="form-control" id="s_part_sale_type_ca" name="s_part_sale_type_ca">
											<option value="">- 전체 -</option>
											<option value="C">고객</option>
											<%-- [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체 --%>
											<%--<option value="A">대리점</option>--%>
											<option value="A">위탁판매점</option>
										</select>
									</td>
									<th>수주종류</th>
									<td>
										<select class="form-control" id="s_preorder_yn" name="s_preorder_yn">
											<option value="">- 전체 -</option>
											<option value="N">일반</option>
											<option value="Y">선주문</option>
										</select>
									</td>
									<th>진행상태</th>
									<td>
										<select class="form-control" id="s_part_type_status_cd" name="s_part_sale_status_cd">
											<option value="">- 전체 -</option>
											<c:forEach items="${codeMap['PART_SALE_STATUS']}" var="item">
												<option value="${item.code_value}" <c:if test="${item.code_value eq '0'}">selected="selected"</c:if>>${item.code_name}</option>
											</c:forEach>
										</select>
									</td>
									<th>센터</th>
									<td>
									<!-- 대리점일 경우, 소속 부서만 조회가능하므로 셀렉트박스로 안함. -->
<%--									<c:if test="${SecureUser.org_type eq 'AGENCY'}">--%>
									<c:if test="${page.fnc.F00029_001 eq 'Y'}">
										<input type="text" class="form-control" value="${SecureUser.org_name}" readonly="readonly">
										<input type="hidden" value="${SecureUser.org_code}" id="s_center_org_code" name="s_center_org_code" readonly="readonly">
									</c:if>
									<!-- 대리점이 아닐 경우, 전체 센터목록 선택가능 -->
<%--									<c:if test="${SecureUser.org_type ne 'AGENCY'}">--%>
									<c:if test="${page.fnc.F00029_001 ne 'Y'}">
										<select class="form-control" id="s_center_org_code" name="s_center_org_code">
											<option value="">- 전체 -</option>
											<c:forEach var="item" items="${codeMap['WAREHOUSE']}">
												<c:if test="${item.code_value ne '4000' && item.code_value ne '5010' && item.code_value ne '4124'}"><option value="${item.code_value}">${item.code_name}</c:if></option>
											</c:forEach>
										</select>
									</c:if>

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
						<h4>수주내역</h4>
						<div class="btn-group">
							<div class="right">
								<label for="s_toggle_column" style="color:black;">
									<input type="checkbox" id="s_toggle_column" onclick="javascript:fnChangeColumn(event)">펼침
								</label>
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
							</div>
						</div>
					</div>
<!-- /그리드 타이틀, 컨트롤 영역 -->

					<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>

<!-- 그리드 서머리, 컨트롤 영역 -->
					<div class="btn-group mt5">
						<div class="left">
							총 <strong class="text-primary" id="total_cnt">0</strong>건
						</div>
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
