<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 자산 > 예금코드관리 > null > null
-- 작성자 : 박예진
-- 최초 작성일 : 2020-04-08 18:03:57
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var depositTypeJson = JSON.parse('${codeMapJsonObj['DEPOSIT_TYPE']}');
		
		$(document).ready(function() {
			createAUIGrid();
		});
		
		// 조회
		function goSearch() {
			var params = {
					"s_deposit_code" : $M.getValue("s_deposit_code"),
					"s_deposit_name" : $M.getValue("s_deposit_name"),
					"s_use_yn" : $M.getValue("s_use_yn"),
					"s_sort_key" : "deposit_code",
					"s_sort_method" : "asc",
				};
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(params), { method : 'get'},
				function(result) {
					if(result.success) { 
						AUIGrid.setGridData(auiGrid, result.list);
						AUIGrid.expandAll(auiGrid);
						$("#total_cnt").html(result.total_cnt);
					}
				}
			);
		}
		
		
		// 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_deposit_code", "s_deposit_name"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch();
				};
			});
		}
		
		// 공지사항 리스트
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "deposit_code",
				rowCheckDependingTree : true,
				showRowNumColumn: true,
				enableFilter :true,
			};
			var columnLayout = [
				{
					dataField : "notice_seq", 
					visible : false
				},
				{ 
					headerText : "코드", 
					dataField : "deposit_code", 
					width : "100",
					minWidth : "100",
					style : "aui-center aui-popup",
					editable : false,
				},
				{ 
					headerText : "명칭", 
					dataField : "deposit_name", 
					width : "260",
					minWidth : "260",
					style : "aui-left",
					editable : false,
				},
				{ 
					headerText : "관리계정코드", 
					dataField : "acnt_code", 
					width : "100",
					minWidth : "100",
					style : "aui-center",
					editable : false,              
					filter : {
		                  showIcon : true
		            }
				},
				{ 
					headerText : "관리계정명칭", 
					dataField : "acnt_name",
					width : "130",
					minWidth : "130",
					style : "aui-center",
					editable : false,               
					filter : {
		                  showIcon : true
		            }
				},
				{ 
					headerText : "거래은행코드", 
					dataField : "deposit_bank_no", 
					width : "180",
					minWidth : "180",
					style : "aui-center",
					editable : false,
				},
				{
					headerText : "예금종류", 
					dataField : "deposit_type_cd", 
					width : "130",
					minWidth : "130",
					style : "aui-center",
					editable : false,
					editRenderer : {
						type : "DropDownListRenderer",
						showEditorBtn : false,
						showEditorBtnOver : false,
						editable : true,
						list : depositTypeJson,
						keyField : "code_value",
						valueField  : "code_name"
					},
					labelFunction : function(  rowIndex, columnIndex, value, headerText, item ) { 
						var retStr = value;
						for(var j = 0; j < depositTypeJson.length; j++) {
							if(depositTypeJson[j]["code_value"] == value) {
								retStr = depositTypeJson[j]["code_name"];
								break;
							}
						}
						return retStr;
					},               
					filter : {
		                  showIcon : true,
						  displayFormatValues : true
		            }
				},
				{
					headerText : "추가코드입력여부", 
					dataField : "add_yn", 
					width : "100",
					minWidth : "100",
					style : "aui-center",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						if(item["add_yn"] == "Y") {
							var template = '입력함';
							return template;
						} else {
						   var template = '입력안함';
						   return template;
						}
					}
				},
				{
					headerText : "구좌번호", 
					dataField : "account_no", 
					width : "200",
					minWidth : "200",
					style : "aui-center",
				},
				{ 
					headerText : "사용여부", 
					dataField : "use_yn", 
					width : "80",
					minWidth : "80",
					style : "aui-center",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						if(item["use_yn"] == "Y") {
							var template = '사용';
							return template;
						} else {
						   var template = '미사용';
						   return template;
						}
					}
				}
			];
			
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();
			AUIGrid.bind(auiGrid, "cellClick", function(event){
				console.log(event.item["use_yn"]);
				if(event.dataField == "deposit_code") {
					var param = {
						"deposit_code" : event.item["deposit_code"],
						"acnt_code" : event.item["acnt_code"]
					};
					var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1100, height=340, left=0, top=0";
					$M.goNextPage('/acnt/acnt0504p01', $M.toGetParam(param), {popupStatus : poppupOption});
				}
				
			});
		}
	
		// 예금신규 등록 페이지 이동
		function goNew() {
			$M.goNextPage("/acnt/acnt050401");
		}
		
		// 엑셀 다운로드
		function fnDownloadExcel() {
			var exportProps = {
			         // 제외항목
			  };
		  	fnExportExcel(auiGrid, "예금코드관리", exportProps);
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
								<col width="120px">								
								<col width="45px">
								<col width="120px">
								<col width="70px">
								<col width="100px">
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<th>예금코드</th>
									<td>
										<input type="text" class="form-control" id="s_deposit_code" name="s_deposit_code">
									</td>
									<th>명칭</th>
									<td>
										<input type="text" class="form-control" id="s_deposit_name" name="s_deposit_name">										
									</td>
									<th>사용구분</th>
									<td>
										<select class="form-control" id="s_use_yn" name="s_use_yn">
											<option value="Y">사용</option>
											<option value="N">미사용</option>
										</select>
									</td>
									<td>
										<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascirpt:goSearch();">조회</button>
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
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
							</div>
						</div>
					</div>
<!-- /조회결과 -->
					<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
					<div class="btn-group mt5">
						<div class="left">
							총 <strong class="text-primary" id="total_cnt">0</strong>건
						</div>
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
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