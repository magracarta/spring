<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 매출관리 > 매출집계조회 > null > null
-- 작성자 : 손광진
-- 최초 작성일 : 2020-09-25 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		var dataFieldName = []; // 펼침 항목(create할때 넣음)
	
		$(document).ready(function() {
			// AUIGrid 생성
			createAUIGrid();
			fnInit();
		});
		
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
		
		//엑셀다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, "매출집계조회", "");
		}
		
		// 시작일자 세팅 현재날짜의 1달 전
		function fnInit() {
// 			var now = "${inputParam.s_current_dt}";
// 			$M.setValue("s_start_dt", $M.addMonths($M.toDate(now), -1));

			<%--if("${page.fnc.F00669_001}" == "Y") {--%>
			<%--	$("#_fnDownloadExcel").removeClass("dpn");--%>
			<%--} else {--%>
			<%--	$("#_fnDownloadExcel").addClass("dpn");--%>
			<%--}--%>
		}
		
		function goSearch() {
			if ($M.validation(document.main_form) == false) {
				return;
			};
			
			if($M.checkRangeByFieldName("s_start_dt", "s_end_dt", true) == false) {
				return;
			}; 
			
			var param = {
				"s_vat_flag" 		: $M.getValue("s_vat_flag"),
				"s_start_dt" 		: $M.getValue("s_start_dt"),
				"s_end_dt" 			: $M.getValue("s_end_dt"),
				"s_org_code_str" 	: $M.getValue("s_org_code"),
				"s_cust_name" 	: $M.getValue("s_cust_name"),
				
				"s_tax_gubun_cd" 		: $M.getValue("s_tax_gubun_cd"),
				"s_issu_gubun_cd" 		: $M.getValue("s_issu_gubun_cd"),
				"s_inout_doc_type_cd" 	: $M.getValue("s_inout_doc_type_cd"),
				"s_issu_yn" 			: $M.getValue("s_issu_yn"),
				"s_duzon_trans_yn" 		: $M.getValue("s_duzon_trans_yn"),
				"s_inout_doc_div_yn" 		: $M.getValue("s_inout_doc_div_yn"),
				s_sort_key : "issue_dt",
				s_sort_method : "desc"
			};
			_fnAddSearchDt(param, 's_start_dt', 's_end_dt');
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						$("#total_cnt").html(result.total_cnt);
						AUIGrid.setGridData(auiGrid, []);
						AUIGrid.setGridData(auiGrid, result.list);
						AUIGrid.collapseAll(auiGrid);
					};
				}
			);
		}
		
		// 엔터키 이벤트
		function enter(fieldObj) {
			var name = fieldObj.name;
			if (name == "s_cust_name") {
				goSearch();
			}
		} 
		
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				// No. 제거
				showRowNumColumn: true,
				headerHeight : 40,
				// 고정칼럼 카운트 지정
				editable : false,
				showFooter : true,
				footerPosition : "top",
				displayTreeOpen : true,
				treeColumnIndex : 5,
			};
			var columnLayout = [
				{
					headerText : "발행일", 
					dataField : "issue_dt", 
					width : "75",
					minWidth : "75",
					style : "aui-center",
					dataType : "date", 
					formatString : "yy-mm-dd",
					 // 그리드 스타일 함수 정의
		            styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
		                 if(item.inout_doc_type_cd != "05" && item.inout_doc_type_cd != "07" && 
		                	item.inout_doc_type_cd != "08") {
		                    return "aui-popup";
		                 };
		                 return null;
					},
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						return item["seq_depth"] != "1" ? '' : value;
					}
				},
				{ 
					headerText : "부서", 
					dataField : "org_name", 
					width : "55",
					minWidth : "45",
					style : "aui-center",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var orgName = value;
						return orgName.replace("센터", "");
					}
				},
				{ 
					headerText : "전표구분", 
					dataField : "inout_doc_type_name", 
					width : "70",
					minWidth : "70",
					style : "aui-center",
				},
				{
					headerText : "전표분리여부",
					dataField : "inout_doc_div_yn",
					width : "80",
					minWidth : "70",
					style : "aui-center",
					labelFunction : function(rowIdex, columnIndex, value, headerText, item) {
						var inoutDocDivYn = value;
						var str = "";
						if (inoutDocDivYn == 'Y') {
							if(item["seq_depth"] == "1") {
								str = "분리(원전표)";
							} else {
								str = "분리";
							}
						}
						return str;
					}
				},
				{ 
					headerText : "전표구분코드", 
					dataField : "inout_doc_type_cd", 
					width : "5%",
					style : "aui-center",
					visible : false,
				},
				{ 
					headerText : "ERP전표번호", 
					dataField : "erp_inout_doc_no", 
					width : "140",
					minWidth : "90",
					style : "aui-center",
					 // 그리드 스타일 함수 정의
		            styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
		                 if(item.inout_doc_type_cd == "05" || item.inout_doc_type_cd == "07" || 
		                	item.inout_doc_type_cd == "08" || item.inout_doc_type_cd == "11") {
		                    return "aui-popup";
		                 };
		                 return null;
					},
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var num = value;
						return num.substring(4, 20);
					}
				},
				{ 
					headerText : "전표구분코드", 
					dataField : "inout_doc_no", 
					width : "5%",
					style : "aui-center",
					visible : false,
				},
				{ 
					headerText : "전자신고일", 
					dataField : "issu_send_dt", 
					width : "75",
					minWidth : "75",
					style : "aui-center",
					dataType : "date", 
					formatString : "yy-mm-dd",
				},
				{ 
					headerText : "회계전송", 
					dataField : "duzon_trans_seq", 
					width : "75",
					minWidth : "75",
					style : "aui-center",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var duzonTransSeq = value;
						if(item["seq_depth"] != "1") {
							duzonTransSeq = "";
						}
						return duzonTransSeq == 0 ? '' : duzonTransSeq;
					}
				},
				{ 
					headerText : "종류", 
					dataField : "tax_gubun", 
					width : "70",
					minWidth : "70",
					style : "aui-center"
				},
				{ 
					headerText : "전표건수", 
					dataField : "inout_cnt",
					width : "60",
					minWidth : "55",
					style : "aui-center",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						return item["seq_depth"] != "1" ? '' : value;
					}
				},
				{ 
					headerText : "고객명", 
					dataField : "cust_name",
					width : "130",
					minWidth : "130",
					style : "aui-center"
				},
				{ 
					headerText : "고객번호", 
					dataField : "cust_no",
					style : "aui-center",
					visible : false,
				},
				{ 
					headerText : "상호", 
					dataField : "breg_name",
					width : "140",
					minWidth : "130",
					style : "aui-center"
				},
				{ 
					headerText : "사업자번호", 
					dataField : "breg_no",
					width : "110",
					minWidth : "100",
					style : "aui-center"
				},
				{ 
					headerText : "적요", 
					dataField : "desc_text",
					width : "150",
					minWidth : "100",
					style : "aui-left"
				},
				{ 
					headerText : "공급가", 
					dataField : "amt",
					width : "120",
					minWidth : "120",
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0",
				},
				{ 
					headerText : "VAT", 
					dataField : "vat_amt",
					width : "100",
					minWidth : "100",
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0",
				},
				{ 
					headerText : "합계", 
					dataField : "tot_amt",
					width : "120",
					minWidth : "120",
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0",
				}
			];
			// 푸터레이아웃
			var footerColumnLayout = [ 
				{
					labelText : "합계",
					positionField : "desc_text",
					style : "aui-center aui-footer",
				}, 
				{
					dataField : "amt",
					positionField : "amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "vat_amt",
					positionField : "vat_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "tot_amt",
					positionField : "tot_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				}
			];
		
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 푸터 객체 세팅
			AUIGrid.setFooter(auiGrid, footerColumnLayout);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();
			
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				// 거래원장상세
				if(event.dataField == "issue_dt" && event.item.inout_doc_type_cd != '05' && event.item.inout_doc_type_cd != '07'
				   && event.item.inout_doc_type_cd != '08') {
					var params = {
						s_cust_no 	: event.item.cust_no,
						s_start_dt 	: event.item.issue_dt,
						s_end_dt	: event.item.issue_dt
					};
					openDealLedgerPanel($M.toGetParam(params));
				} else if(event.dataField == "erp_inout_doc_no" && (event.item.inout_doc_type_cd == '05' || event.item.inout_doc_type_cd == '07'
						  || event.item.inout_doc_type_cd == '08' || event.item.inout_doc_type_cd == '11')) {
					console.log("event : ", event);
					if (event.treeIcon) {
						return;
					}
					// 매출처리
					var params = {
						inout_doc_no : event.item.inout_doc_no,
					};
					var popupOption = "";
					$M.goNextPage('/cust/cust0202p01', $M.toGetParam(params), {popupStatus : popupOption});
				}

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
<!-- 검색영역 -->					
					<div class="search-wrap">				
						<table class="table">
							<colgroup>
								<col width="65px">
								<col width="260px">								
								<col width="40px">
								<col width="100px">
								<col width="50px">
								<col width="140px">
								<col width="70px">
								<col width="100px">
								<col width="55px">
								<col width="65px">
								<col width="55px">
								<col width="65px">
								<col width="55px">
								<col width="65px">
								<col width="80px">
								<col width="65px">
								<col width="80px">
								<col width="65px">
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<th>발행일자</th>
									<td>
										<div class="form-row inline-pd">
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" alt="" value="${searchDtMap.s_start_dt}">
												</div>
											</div>
											<div class="col-auto">~</div>
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" alt="" value="${searchDtMap.s_end_dt}">
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
									<!-- <td>
										<div class="form-row inline-pd widthfix">
											<div class="col width80px">
												<div class="input-group">
													<input type="text" class="form-control border-right-0">
													<button type="button" class="btn btn-icon btn-primary-gra"><i class="material-iconsdate_range"></i></button>
												</div>
											</div>
											<div class="col width16px text-center">~</div>
											<div class="col width80px">
												<div class="input-group">
													<input type="text" class="form-control border-right-0">
													<button type="button" class="btn btn-icon btn-primary-gra"><i class="material-iconsdate_range"></i></button>
												</div>
											</div>
										</div>
									</td> -->
									<th>고객명</th>
	                                <td>
										<input type="text" class="form-control" id="s_cust_name" name="s_cust_name">
	                                </td>
									<th>부서</th>
	                                <td>
										<input class="form-control" style="width: 99%;" type="text" id="s_org_code" name="s_org_code" easyui="combogrid"
										easyuiname="centerList" panelwidth="300" idfield="org_code" textfield="org_name" multi="Y"/>
	                                </td>
									<th>계산서구분</th>
									<td>
										<select class="form-control" id="s_tax_gubun_cd" name="s_tax_gubun_cd">
											<option value="">- 전체 -</option>
											<option value="V">세금계산서</option>
											<option value="F">수정계산서</option>
											<option value="C">카드매출</option>
											<option value="A">현금영수증</option>
											<option value="N">무증빙</option>
											<option value="X">미지정</option>
										</select>
									</td>
									<th>발행구분</th>
									<td>
										<select class="form-control" id="s_issu_gubun_cd" name="s_issu_gubun_cd">
											<option value="">- 전체 -</option>
											<option value="S">합산</option>
											<option value="P">개별</option>
											<option value="T">가발행</option>
										</select>
									</td>
									<th>매출구분</th>
									<td>
										<select class="form-control" id="s_inout_doc_type_cd" name="s_inout_doc_type_cd">
											<option value="">- 전체 -</option>
											<c:forEach items="${codeMap['TAXBILL_DOC_TYPE']}" var="item">
											<option value="${item.code_value}">${item.code_name}</option>
											</c:forEach>
										</select>
									</td>
									<th>신고여부</th>
									<td>
										<select class="form-control" id="s_issu_yn" name="s_issu_yn">
											<option value="">- 전체 -</option>
											<option value="Y">신고</option>
											<option value="N">미신고</option>
										</select>
									</td>
									<th>회계전송여부</th>
									<td>
										<select class="form-control" id="s_duzon_trans_yn" name="s_duzon_trans_yn">
											<option value="">- 전체 -</option>
											<option value="Y">전송</option>
											<option value="N">미전송</option>
										</select>
									</td>
									<th>분리전표여부</th>
									<td>
										<select class="form-control" id="s_inout_doc_div_yn" name="s_inout_doc_div_yn">
											<option value="">- 전체 -</option>
											<option value="Y">분리</option>
											<option value="N">미분리</option>
										</select>
									</td>
									<td>
										<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
									</td>									
								</tr>						
							</tbody>
						</table>					
					</div>
<!-- /검색영역 -->
<!-- 조회결과 -->
					<div class="title-wrap mt10">
						<h4>조회결과</h4>
						<div class="btn-group">
							<div class="right">
								<button type="button" onclick=AUIGrid.expandAll(auiGrid); class="btn btn-default"><i class="material-iconsadd text-default"></i>전체펼치기</button>
								<button type="button" onclick=AUIGrid.collapseAll(auiGrid); class="btn btn-default"><i class="material-iconsremove text-default"></i>전체접기</button>
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</div>
					</div>
<!-- /조회결과 -->
					<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
					<div class="btn-group mt5">
						<div class="left">
							총 <strong class="text-primary" id="total_cnt">0</strong>건
						</div>		
					</div>				
				</div>
			</div>		
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
		</div>
<!-- /contents 전체 영역 -->	
</div>	
</form>
</body>
</html>